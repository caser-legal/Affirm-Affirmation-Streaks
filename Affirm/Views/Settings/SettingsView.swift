import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("appearanceMode") private var appearanceMode = 0
    
    @Environment(\.modelContext) private var modelContext
    @Query private var stats: [UserStats]
    @Query private var affirmations: [Affirmation]
    @Query(filter: #Predicate<Affirmation> { $0.isFavorite }) private var favorites: [Affirmation]
    
    @AppStorage("showResetFavoritesAlert") private var showResetFavoritesAlert = false
    @AppStorage("showResetStreakAlert") private var showResetStreakAlert = false
    @State private var showClearAllDataAlert = false
    @State private var reminderTime = Date()
    @AppStorage("showPermissionAlert") private var showPermissionAlert = false
    @AppStorage("showPaywall") private var showPaywall = false
    @State private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 21) {
                    // Premium Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [AppColors.warmCoral.opacity(0.3), .clear],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.warmCoral, AppColors.sunsetOrange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 76, height: 76)
                            
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(spacing: 6) {
                            Text("Your Journey")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            
                            HStack(spacing: 21) {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("\(stats.first?.currentStreak ?? 0)")
                                        .fontWeight(.semibold)
                                    Text("day streak")
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(AppColors.warmCoral)
                                    Text("\(favorites.count)")
                                        .fontWeight(.semibold)
                                    Text("favorites")
                                }
                            }
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24))
                    
                    // Upgrade to Pro Section
                    upgradeSection
                    
                    // Notifications Section
                    SettingsSection(title: "Notifications", icon: "bell.fill", iconColor: .orange) {
                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                icon: "bell.badge.fill",
                                iconColor: .orange,
                                title: "Daily Reminder",
                                isOn: $dailyReminderEnabled
                            )
                            .onChange(of: dailyReminderEnabled) { _, enabled in
                                if enabled { requestAndScheduleNotification() }
                                else { cancelNotification() }
                            }
                            
                            if dailyReminderEnabled {
                                Divider().padding(.leading, 56)
                                
                                HStack(spacing: 13) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.blue)
                                    }
                                    
                                    Text("Time")
                                        .font(.system(size: 16, design: .rounded))
                                    
                                    Spacer()
                                    
                                    if subscriptionManager.isPro {
                                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .onChange(of: reminderTime) { _, _ in updateReminderTime() }
                                    } else {
                                        Button {
                                            showPaywall = true
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text("9:00 AM")
                                                    .foregroundStyle(.secondary)
                                                Image(systemName: "lock.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(Color(hex: "FFD700"))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider().padding(.leading, 56)
                                
                                Button {
                                    sendTestNotification()
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                } label: {
                                    HStack(spacing: 13) {
                                        ZStack {
                                            Circle()
                                                .fill(AppColors.warmCoral.opacity(0.12))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "paperplane.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(AppColors.warmCoral)
                                        }
                                        
                                        Text("Send Test Notification")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .accessibilityLabel("Send test notification")
                            }
                        }
                    }
                    
                    // Appearance Section
                    SettingsSection(title: "Appearance", icon: "paintbrush.fill", iconColor: .purple) {
                        VStack(spacing: 0) {
                            ForEach(Array(["System", "Light", "Dark"].enumerated()), id: \.offset) { index, mode in
                                if index > 0 { Divider().padding(.leading, 56) }
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        appearanceMode = index
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    HStack(spacing: 13) {
                                        ZStack {
                                            Circle()
                                                .fill(themeColor(for: index).opacity(0.12))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: themeIcon(for: index))
                                                .font(.system(size: 16))
                                                .foregroundStyle(themeColor(for: index))
                                        }
                                        
                                        Text(mode)
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        if appearanceMode == index {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(AppColors.warmCoral)
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    
                    // Data Section
                    SettingsSection(title: "Data", icon: "externaldrive.fill", iconColor: .green) {
                        VStack(spacing: 0) {
                            Button(role: .destructive) {
                                showResetFavoritesAlert = true
                            } label: {
                                SettingsActionRow(
                                    icon: "heart.slash.fill",
                                    iconColor: .red,
                                    title: "Reset Favorites",
                                    subtitle: "\(favorites.count) saved"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            Divider().padding(.leading, 56)
                            
                            Button(role: .destructive) {
                                showResetStreakAlert = true
                            } label: {
                                SettingsActionRow(
                                    icon: "flame.fill",
                                    iconColor: .orange,
                                    title: "Reset Streak",
                                    subtitle: "\(stats.first?.currentStreak ?? 0) days"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            Divider().padding(.leading, 56)
                            
                            ShareLink(item: exportAffirmations()) {
                                SettingsActionRow(
                                    icon: "square.and.arrow.up.fill",
                                    iconColor: .blue,
                                    title: "Export Affirmations",
                                    showChevron: true
                                )
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            Button(role: .destructive) {
                                showClearAllDataAlert = true
                            } label: {
                                SettingsActionRow(
                                    icon: "trash.fill",
                                    iconColor: .red,
                                    title: "Clear All Data",
                                    subtitle: "Reset everything"
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    
                    // About Section
                    SettingsSection(title: "About", icon: "info.circle.fill", iconColor: .gray) {
                        VStack(spacing: 0) {
                            HStack(spacing: 13) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "number")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.gray)
                                }
                                
                                Text("Version")
                                    .font(.system(size: 16, design: .rounded))
                                
                                Spacer()
                                
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider().padding(.leading, 56)
                            
                            Link(destination: URL(string: "https://apps.apple.com")!) {
                                SettingsActionRow(
                                    icon: "star.fill",
                                    iconColor: .yellow,
                                    title: "Rate App",
                                    showChevron: true
                                )
                            }
                            
                            Divider().padding(.leading, 56)
                            
                            Link(destination: URL(string: "https://apple.caserlegal.com/#privacy")!) {
                                SettingsActionRow(
                                    icon: "hand.raised.fill",
                                    iconColor: .blue,
                                    title: "Privacy Policy",
                                    showChevron: true
                                )
                            }
                        }
                    }
                }
                .padding(21)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPaywall = true
                    } label: {
                        Image(systemName: subscriptionManager.isPro ? "star.fill" : "star")
                            .foregroundStyle(AppColors.warmCoral)
                    }
                    .accessibilityLabel(subscriptionManager.isPro ? "Pro Subscriber" : "Upgrade to Pro")
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("Reset Favorites?", isPresented: $showResetFavoritesAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { resetFavorites() }
        } message: {
            Text("This will remove all saved favorites.")
        }
        .alert("Reset Streak?", isPresented: $showResetStreakAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { resetStreak() }
        } message: {
            Text("This will reset your current streak to 0.")
        }
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { dailyReminderEnabled = false }
        } message: {
            Text("Please enable notifications in Settings to receive daily affirmation reminders.")
        }
        .onAppear {
            reminderTime = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
        }
    }
    
    @ViewBuilder
    private var upgradeSection: some View {
        if !subscriptionManager.isPro {
            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "FFD700"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to Pro").font(.headline).foregroundStyle(.primary)
                        Text("Unlock all features").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 21))
                .overlay(RoundedRectangle(cornerRadius: 21).fill(Color(hex: "FFD700").opacity(0.1)))
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: 13) {
                Image(systemName: "checkmark.seal.fill").font(.title2).foregroundStyle(Color(hex: "4CAF50"))
                Text("Pro Active").font(.headline)
                Spacer()
                Text("Thank you!").font(.caption).foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 21))
        }
    }
    
    private func themeIcon(for index: Int) -> String {
        switch index {
        case 0: return "circle.lefthalf.filled"
        case 1: return "sun.max.fill"
        case 2: return "moon.fill"
        default: return "circle"
        }
    }
    
    private func themeColor(for index: Int) -> Color {
        switch index {
        case 0: return .purple
        case 1: return .orange
        case 2: return .indigo
        default: return .gray
        }
    }
    
    private func updateReminderTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        reminderHour = components.hour ?? 9
        reminderMinute = components.minute ?? 0
        if dailyReminderEnabled { scheduleNotification() }
    }
    
    private func requestAndScheduleNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted { scheduleNotification() }
                else { showPermissionAlert = true }
            }
        }
    }
    
    private func scheduleNotification() {
        let randomAffirmation = affirmations.randomElement()
        let content = UNMutableNotificationContent()
        content.title = "Daily Affirmation"
        content.body = randomAffirmation?.text ?? "Start your day with positivity!"
        content.sound = .default
        if let id = randomAffirmation?.id { content.userInfo = ["affirmationID": id.uuidString] }
        
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyAffirmation", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyAffirmation"])
    }
    
    private func sendTestNotification() {
        let randomAffirmation = affirmations.randomElement()
        let content = UNMutableNotificationContent()
        content.title = "Daily Affirmation"
        content.body = randomAffirmation?.text ?? "You are amazing!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func resetFavorites() {
        for favorite in favorites { favorite.isFavorite = false }
    }
    
    private func resetStreak() {
        if let userStats = stats.first { userStats.currentStreak = 0 }
    }
    
    private func exportAffirmations() -> String {
        favorites.map { "\($0.text) - \($0.category.rawValue)" }.joined(separator: "\n")
    }
}

// MARK: - Supporting Views

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
            
            content
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, design: .rounded))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppColors.warmCoral)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
