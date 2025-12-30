import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(filter: #Predicate<Affirmation> { $0.isFavorite }) private var favorites: [Affirmation]
    @State private var sortOption: SortOption = .dateAdded
    @State private var selectedAffirmation: Affirmation?
    @Namespace private var animation
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case category = "Category"
        case alphabetical = "Alphabetical"
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 13),
        GridItem(.flexible(), spacing: 13)
    ]
    
    var sortedFavorites: [Affirmation] {
        switch sortOption {
        case .dateAdded:
            return favorites.sorted { $0.createdAt > $1.createdAt }
        case .category:
            return favorites.sorted { $0.categoryRaw < $1.categoryRaw }
        case .alphabetical:
            return favorites.sorted { $0.text < $1.text }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if favorites.isEmpty {
                    EmptyFavoritesView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Stats header
                            HStack(spacing: 16) {
                                StatPill(icon: "heart.fill", value: "\(favorites.count)", label: "saved")
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                sortOption = option
                                            }
                                        } label: {
                                            HStack {
                                                Text(option.rawValue)
                                                if sortOption == option {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.up.arrow.down")
                                            .font(.system(size: 12, weight: .semibold))
                                        Text(sortOption.rawValue)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                    }
                                    .foregroundStyle(AppColors.warmCoral)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.warmCoral.opacity(0.12), in: Capsule())
                                }
                            }
                            .padding(.horizontal, 21)
                            
                            LazyVGrid(columns: columns, spacing: 13) {
                                ForEach(sortedFavorites) { affirmation in
                                    FavoriteCard(
                                        affirmation: affirmation,
                                        namespace: animation,
                                        onTap: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                selectedAffirmation = affirmation
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 21)
                            .padding(.bottom, 34)
                        }
                        .padding(.top, 8)
                    }
                }
                
                if let selected = selectedAffirmation {
                    FullCardView(
                        affirmation: selected,
                        namespace: animation,
                        onDismiss: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedAffirmation = nil
                            }
                        }
                    )
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(AppColors.warmCoral)
            Text("\(value) \(label)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

struct EmptyFavoritesView: View {
    @State private var heartScale: CGFloat = 1.0
    @State private var ringScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                // Animated glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.warmCoral.opacity(glowOpacity), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // Animated rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(AppColors.warmCoral.opacity(0.12 - Double(i) * 0.03), lineWidth: 1.5)
                        .frame(width: CGFloat(100 + i * 28), height: CGFloat(100 + i * 28))
                        .scaleEffect(ringScale)
                }
                
                Circle()
                    .fill(AppColors.warmCoral.opacity(0.1))
                    .frame(width: 88, height: 88)
                
                Image(systemName: "heart")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(AppColors.warmCoral)
                    .scaleEffect(heartScale)
            }
            
            VStack(spacing: 10) {
                Text("No Favorites Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("Double-tap any card to save\nyour favorite affirmations")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(40)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                heartScale = 1.1
                ringScale = 1.05
                glowOpacity = 0.5
            }
        }
    }
}

struct FavoriteCard: View {
    let affirmation: Affirmation
    let namespace: Namespace.ID
    let onTap: () -> Void
    @Environment(\.modelContext) private var modelContext
    @Query private var allAffirmations: [Affirmation]
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete action
            Button {
                withAnimation(.spring(response: 0.3)) {
                    affirmation.isFavorite = false
                    syncFavorites()
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 20))
                    Text("Remove")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(.red.gradient, in: RoundedRectangle(cornerRadius: 20))
            
            // Card content
            VStack(alignment: .leading, spacing: 12) {
                Text(affirmation.text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(4)
                
                Spacer(minLength: 0)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: affirmation.category.icon)
                            .font(.system(size: 10))
                        Text(affirmation.category.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(affirmation.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(affirmation.category.color.opacity(0.12), in: Capsule())
                    
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.warmCoral.opacity(0.6))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(affirmation.category.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(affirmation.category.color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: affirmation.category.color.opacity(0.15), radius: 10, y: 5)
            .matchedGeometryEffect(id: affirmation.id, in: namespace)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -100)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3)) {
                            if value.translation.width < -60 {
                                affirmation.isFavorite = false
                                syncFavorites()
                            }
                            offset = 0
                        }
                    }
            )
            .onTapGesture {
                if offset == 0 {
                    onTap()
                } else {
                    withAnimation(.spring(response: 0.3)) { offset = 0 }
                }
            }
        }
    }
    
    private func syncFavorites() {
        guard SubscriptionManager.shared.isPro else { return }
        let favoriteIDs = allAffirmations.filter { $0.isFavorite }.map { $0.id }
        iCloudSyncManager.shared.syncFavorites(favoriteIDs)
    }
}

struct FullCardView: View {
    let affirmation: Affirmation
    let namespace: Namespace.ID
    let onDismiss: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var cardHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 500 : 420
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 0) {
                // Dismiss indicator
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white.opacity(0.9), .white.opacity(0.2))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal, 21)
                .padding(.bottom, 13)
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Text(affirmation.text)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 28)
                    
                    Spacer()
                    
                    HStack {
                        CategoryBadge(category: affirmation.category)
                        Spacer()
                        ShareLink(item: affirmation.text) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.5), in: Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(width: 320, height: cardHeight)
                .background(affirmation.category.cardGradient, in: RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(AppColors.goldenYellow, lineWidth: 3)
                )
                .shadow(color: AppColors.goldenYellow.opacity(0.4), radius: 24, y: 10)
                .matchedGeometryEffect(id: affirmation.id, in: namespace)
            }
        }
    }
}
