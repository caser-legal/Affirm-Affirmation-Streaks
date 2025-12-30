import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var stats: [UserStats]
    @Query private var dailyLogs: [DailyLog]
    
    private var userStats: UserStats? { stats.first }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradientBackground()
                
                ScrollView {
                    VStack(spacing: 21) {
                        StreakCard(
                            currentStreak: userStats?.currentStreak ?? 0,
                            longestStreak: userStats?.longestStreak ?? 0
                        )
                        
                        StatsGrid(
                            totalViewed: userStats?.totalAffirmationsViewed ?? 0,
                            favoriteCategory: userStats?.favoriteCategory
                        )
                        
                        CalendarHeatMap(logs: dailyLogs)
                        
                        MotivationalMessage(streak: userStats?.currentStreak ?? 0)
                    }
                    .padding(21)
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Progress")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white.opacity(0.9), .white.opacity(0.2))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("Close statistics")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    @State private var flameScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 16) {
            // Animated flame with premium glow
            ZStack {
                // Animated glow rings
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orange.opacity(glowOpacity - Double(i) * 0.15), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: CGFloat(60 + i * 20)
                            )
                        )
                        .frame(width: CGFloat(120 + i * 40), height: CGFloat(120 + i * 40))
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
                    .shadow(color: .orange.opacity(0.5), radius: 15)
            }
            
            VStack(spacing: 4) {
                Text("\(currentStreak)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                Text("Day Streak")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            // Divider with gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .primary.opacity(0.1), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.vertical, 8)
            
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.orange)
                    Text("Best Streak")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(longestStreak) days")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                flameScale = 1.08
                glowOpacity = 0.6
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current streak: \(currentStreak) days. Best streak: \(longestStreak) days")
    }
}

struct StatsGrid: View {
    let totalViewed: Int
    let favoriteCategory: AffirmationCategory?
    
    var body: some View {
        HStack(spacing: 13) {
            StatBox(
                icon: "eye.fill",
                iconColor: .blue,
                value: "\(totalViewed)",
                label: "Viewed"
            )
            
            StatBox(
                icon: favoriteCategory?.icon ?? "heart.fill",
                iconColor: favoriteCategory?.color ?? AppColors.warmCoral,
                value: favoriteCategory?.rawValue ?? "None",
                label: "Top Category"
            )
        }
    }
}

struct StatBox: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(iconColor)
            }
            
            Text(value)
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Text(label)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(21)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 21))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct CalendarHeatMap: View {
    let logs: [DailyLog]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Activity")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<28, id: \.self) { dayOffset in
                    let date = calendar.date(byAdding: .day, value: -27 + dayOffset, to: Date()) ?? Date()
                    let log = logs.first { calendar.isDate($0.date, inSameDayAs: date) }
                    let isToday = calendar.isDateInToday(date)
                    
                    CalendarDayCell(
                        hasActivity: log != nil,
                        activityCount: log?.affirmationsViewedIDs.count ?? 0,
                        isToday: isToday
                    )
                }
            }
            
            // Legend
            HStack(spacing: 8) {
                Text("Less")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                
                ForEach([0.2, 0.4, 0.7, 1.0], id: \.self) { opacity in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppColors.warmCoral.opacity(opacity))
                        .frame(width: 12, height: 12)
                }
                
                Text("More")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.top, 4)
        }
        .padding(21)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 21))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Activity calendar showing \(logs.count) active days in the last 28 days")
    }
}

struct CalendarDayCell: View {
    let hasActivity: Bool
    let activityCount: Int
    let isToday: Bool
    
    private var intensity: Double {
        guard hasActivity else { return 0.15 }
        switch activityCount {
        case 1...3: return 0.4
        case 4...7: return 0.7
        default: return 1.0
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(hasActivity ? AppColors.warmCoral.opacity(intensity) : .white.opacity(0.15))
            .frame(height: 24)
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.white, lineWidth: 2)
                }
            }
    }
}

struct MotivationalMessage: View {
    let streak: Int
    
    var message: String {
        switch streak {
        case 0: return "Start your journey today! ✨"
        case 1...6: return "Great start! Keep going! 💪"
        case 7...13: return "One week strong! 🎉"
        case 14...29: return "Two weeks of positivity! 🌟"
        case 30...99: return "A month of growth! 🚀"
        default: return "You're unstoppable! 🔥"
        }
    }
    
    var body: some View {
        Text(message)
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(21)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 21))
            .accessibilityLabel("Motivation: \(message)")
    }
}
