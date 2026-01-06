import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @Query private var allAffirmations: [Affirmation]
    @Query(filter: #Predicate<Affirmation> { $0.isFavorite }) private var favorites: [Affirmation]
    @Query private var stats: [UserStats]
    @AppStorage("selectedCategories") private var selectedCategoriesData: Data = Data()
    @AppStorage("lastCelebratedStreak") private var lastCelebratedStreak = 0
    @AppStorage("currentIndex") private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showStats = false
    @State private var hasRecordedActivity = false
    @State private var showMilestone = false
    @State private var milestoneStreak = 0
    @State private var showPaywall = false
    @State private var subscriptionManager = SubscriptionManager.shared
    
    private static let freeFavoritesLimit = 5
    
    private var userStats: UserStats? { stats.first }
    
    private var selectedCategories: Set<AffirmationCategory> {
        guard let rawValues = try? JSONDecoder().decode([String].self, from: selectedCategoriesData) else {
            return []
        }
        return Set(rawValues.compactMap { AffirmationCategory(rawValue: $0) })
    }
    
    private var affirmations: [Affirmation] {
        if selectedCategories.isEmpty {
            return allAffirmations
        }
        return allAffirmations.filter { selectedCategories.contains($0.category) }
    }
    
    var body: some View {
        ZStack {
            MeshGradientBackground()
            
            VStack(spacing: 0) {
                // Premium header with streak pill
                HStack(spacing: 13) {
                    Button(action: { showStats = true }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(.orange.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.orange)
                            }
                            Text("\(userStats?.currentStreak ?? 0)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                        }
                        .padding(.leading, 6)
                        .padding(.trailing, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("View streak statistics")
                    
                    Spacer()
                    
                    Button(action: shuffleCards) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("Shuffle affirmations")
                }
                .padding(.horizontal, 21)
                .padding(.top, 13)
                
                // Upgrade to Pro banner
                if !subscriptionManager.isPro {
                    Button { showPaywall = true } label: {
                        HStack(spacing: 13) {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color(hex: "FFD700"))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to Pro").font(.headline)
                                Text("Unlock all features").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                        .padding(13)
                        .background(Color(hex: "FFD700").opacity(0.15), in: RoundedRectangle(cornerRadius: 13))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 21)
                    .padding(.top, 13)
                }
                
                Spacer()
                
                if !affirmations.isEmpty {
                    CardDeckView(
                        affirmations: affirmations,
                        currentIndex: $currentIndex,
                        dragOffset: $dragOffset,
                        onFavorite: favoriteCurrentCard,
                        onSwipe: recordView
                    )
                } else {
                    EmptyDeckView()
                }
                
                Spacer()
            }
            
            if showMilestone {
                MilestoneOverlay(streak: milestoneStreak, onDismiss: { showMilestone = false })
            }
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            if !hasRecordedActivity {
                StreakManager.shared.recordActivity(context: modelContext)
                hasRecordedActivity = true
                checkMilestone()
            }
        }
        .onChange(of: selectedCategoriesData) { _, _ in
            currentIndex = 0
        }
        .onChange(of: notificationManager.pendingAffirmationID) { _, newID in
            if let id = newID, let index = affirmations.firstIndex(where: { $0.id == id }) {
                currentIndex = index
                notificationManager.pendingAffirmationID = nil
            }
        }
    }
    
    private func checkMilestone() {
        guard let streak = userStats?.currentStreak else { return }
        let milestones = [7, 14, 21, 30, 60, 90, 100, 365]
        
        if milestones.contains(streak) && streak > lastCelebratedStreak {
            milestoneStreak = streak
            lastCelebratedStreak = streak
            withAnimation(.spring()) {
                showMilestone = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    private func shuffleCards() {
        guard !affirmations.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        currentIndex = Int.random(in: 0..<affirmations.count)
        recordView()
    }
    
    private func recordView() {
        guard currentIndex < affirmations.count else { return }
        StreakManager.shared.recordAffirmationViewed(
            affirmationID: affirmations[currentIndex].id,
            context: modelContext
        )
    }
    
    private func favoriteCurrentCard() {
        guard currentIndex < affirmations.count else { return }
        let affirmation = affirmations[currentIndex]
        
        // If trying to add favorite (not remove), check limit
        if !affirmation.isFavorite {
            if !subscriptionManager.isPro && favorites.count >= Self.freeFavoritesLimit {
                showPaywall = true
                return
            }
        }
        
        affirmation.isFavorite.toggle()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        StreakManager.shared.updateFavoriteCategory(context: modelContext)
        
        // Sync favorites to iCloud (Pro only)
        if subscriptionManager.isPro {
            let favoriteIDs = allAffirmations.filter { $0.isFavorite }.map { $0.id }
            iCloudSyncManager.shared.syncFavorites(favoriteIDs)
        }
    }
}

struct EmptyDeckView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "rectangle.stack")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.primary.opacity(0.9))
                    .symbolEffect(.pulse.byLayer)
            }
            
            VStack(spacing: 8) {
                Text("No Affirmations")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Select categories to see affirmations")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
    }
}

struct CardDeckView: View {
    let affirmations: [Affirmation]
    @Binding var currentIndex: Int
    @Binding var dragOffset: CGSize
    let onFavorite: () -> Void
    let onSwipe: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showHeart = false
    @State private var showGlow = false
    @State private var particles: [ParticleData] = []
    
    private var visibleCount: Int { min(3, affirmations.count) }
    private var topOffset: Int { max(0, visibleCount - 1) }
    
    var body: some View {
        ZStack {
            ForEach(0..<visibleCount, id: \.self) { offset in
                let depth = topOffset - offset
                let index = (currentIndex + depth) % affirmations.count
                AffirmationCard(affirmation: affirmations[index])
                    .scaleEffect(scale(for: depth))
                    .offset(y: CGFloat(depth) * 8)
                    .zIndex(Double(offset))
                    .offset(x: offset == topOffset ? dragOffset.width : 0)
                    .rotationEffect(.degrees(offset == topOffset && !reduceMotion ? Double(dragOffset.width / 20) : 0))
                    .rotation3DEffect(
                        .degrees(offset == topOffset && !reduceMotion ? Double(dragOffset.width / 10) : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.goldenYellow, lineWidth: showGlow && offset == topOffset ? 6 : 0)
                            .shadow(color: showGlow && offset == topOffset ? AppColors.goldenYellow : .clear, radius: 20)
                    )
            }
            
            // Particle burst (only if reduce motion is off)
            if !reduceMotion {
                ForEach(particles) { particle in
                    Circle()
                        .fill(AppColors.warmCoral)
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.warmCoral)
                    .scaleEffect(showHeart && !reduceMotion ? 1.3 : 1.0)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    handleSwipe(value)
                }
        )
        .onTapGesture(count: 2) {
            triggerFavoriteAnimation()
            onFavorite()
        }
    }
    
    private func triggerFavoriteAnimation() {
        if reduceMotion {
            showHeart = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showHeart = false
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                showHeart = true
                showGlow = true
            }
            createParticles()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showHeart = false
                    showGlow = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                particles.removeAll()
            }
        }
    }
    
    private func createParticles() {
        particles = (0..<12).map { i in
            let angle = Double(i) * (360.0 / 12.0) * .pi / 180.0
            return ParticleData(
                id: UUID(),
                x: 0, y: 0,
                targetX: cos(angle) * 80,
                targetY: sin(angle) * 80,
                size: CGFloat.random(in: 6...12),
                opacity: 1.0
            )
        }
        withAnimation(.easeOut(duration: 0.5)) {
            for i in particles.indices {
                particles[i].x = particles[i].targetX
                particles[i].y = particles[i].targetY
                particles[i].opacity = 0
            }
        }
    }
    
    private func scale(for offset: Int) -> CGFloat {
        switch offset {
        case 0: return 1.0
        case 1: return 0.95
        case 2: return 0.9
        default: return 0.85
        }
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let threshold: CGFloat = 100
        let animation: Animation = reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.7)
        
        if value.translation.width > threshold {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(animation) {
                currentIndex = (currentIndex + 1) % affirmations.count
                dragOffset = .zero
            }
            onSwipe()
        } else if value.translation.width < -threshold {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(animation) {
                currentIndex = (currentIndex - 1 + affirmations.count) % affirmations.count
                dragOffset = .zero
            }
            onSwipe()
        } else if value.translation.height < -threshold {
            triggerFavoriteAnimation()
            onFavorite()
            withAnimation(animation) {
                dragOffset = .zero
            }
        } else {
            withAnimation(animation) {
                dragOffset = .zero
            }
        }
    }
}

struct ParticleData: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var targetX: CGFloat
    var targetY: CGFloat
    var size: CGFloat
    var opacity: Double
}

struct MilestoneOverlay: View {
    let streak: Int
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var flameScale: CGFloat = 1.0
    @State private var confettiVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var message: String {
        switch streak {
        case 7: return "One week strong!"
        case 14: return "Two weeks of growth!"
        case 21: return "Habit formed!"
        case 30: return "One month! Amazing!"
        case 60: return "Two months! Incredible!"
        case 90: return "Three months! Unstoppable!"
        case 100: return "100 days! Legend!"
        case 365: return "One year! Extraordinary!"
        default: return "Milestone reached!"
        }
    }
    
    private var emoji: String {
        switch streak {
        case 7: return "🎉"
        case 14: return "🌱"
        case 21: return "💪"
        case 30: return "🌟"
        case 60: return "🔥"
        case 90: return "🚀"
        case 100: return "👑"
        case 365: return "🏆"
        default: return "🎊"
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 24) {
                ZStack {
                    // Glow rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(AppColors.goldenYellow.opacity(0.2 - Double(i) * 0.05), lineWidth: 2)
                            .frame(width: CGFloat(100 + i * 30), height: CGFloat(100 + i * 30))
                            .scaleEffect(confettiVisible ? 1.2 : 0.8)
                            .opacity(confettiVisible ? 0 : 1)
                    }
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, AppColors.warmCoral],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(flameScale)
                        .shadow(color: .orange.opacity(0.6), radius: 20)
                }
                
                VStack(spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Day Streak")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Text("\(message) \(emoji)")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                
                Button(action: onDismiss) {
                    Text("Keep Going")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.deepCoral)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(.white, in: Capsule())
                        .shadow(color: .white.opacity(0.3), radius: 12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.warmCoral, AppColors.deepCoral],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppColors.warmCoral.opacity(0.5), radius: 30, y: 10)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            if reduceMotion {
                scale = 1.0
                opacity = 1.0
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    flameScale = 1.1
                }
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    confettiVisible = true
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(streak) day streak milestone. \(message)")
        .accessibilityHint("Tap to dismiss")
    }
}
