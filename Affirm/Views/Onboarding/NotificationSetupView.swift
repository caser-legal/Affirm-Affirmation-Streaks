import SwiftUI
import UserNotifications

struct NotificationSetupView: View {
    @Binding var reminderTime: Date
    let onComplete: () -> Void
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var bellScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Premium bell icon with glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.goldenYellow.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.goldenYellow)
                    .scaleEffect(bellScale)
                    .shadow(color: AppColors.goldenYellow.opacity(0.4), radius: 15)
            }
            
            VStack(spacing: 14) {
                Text("Stay Inspired Daily")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Get a daily reminder to read\nyour affirmations")
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // Time picker with label
            VStack(spacing: 8) {
                Text("Reminder Time")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                
                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 16) {
                if !notificationsEnabled {
                    Button(action: requestNotifications) {
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16))
                            Text("Enable Notifications")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(AppColors.deepCoral)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .white.opacity(0.3), radius: 12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Button(action: onComplete) {
                    HStack(spacing: 8) {
                        Text(notificationsEnabled ? "Start Affirming" : "Skip for Now")
                            .font(.system(size: notificationsEnabled ? 17 : 15, weight: notificationsEnabled ? .semibold : .medium, design: .rounded))
                        if notificationsEnabled {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundStyle(notificationsEnabled ? AppColors.deepCoral : .white.opacity(0.8))
                    .frame(maxWidth: notificationsEnabled ? .infinity : nil)
                    .padding(.vertical, notificationsEnabled ? 18 : 0)
                    .background(notificationsEnabled ? .white : .clear, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: notificationsEnabled ? .white.opacity(0.3) : .clear, radius: 12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 34)
            .padding(.bottom, 55)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bellScale = 1.08
            }
        }
    }
    
    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification()
                }
                notificationsEnabled = true
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Affirmation"
        content.body = "Start your day with positivity!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyAffirmation", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
