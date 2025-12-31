import SwiftUI

struct OnboardingView: View {
    @AppStorage("currentStep") private var currentStep = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedCategories: Set<AffirmationCategory> = []
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    
    var body: some View {
        ZStack {
            MeshGradientBackground()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
                }
                
                switch currentStep {
                case 0:
                    WelcomeView(onContinue: { currentStep = 1 })
                case 1:
                    CategorySelectionView(
                        selectedCategories: $selectedCategories,
                        onContinue: { currentStep = 2 }
                    )
                case 2:
                    NotificationSetupView(
                        reminderTime: $reminderTime,
                        onComplete: completeOnboarding
                    )
                default:
                    EmptyView()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct WelcomeView: View {
    let onContinue: () -> Void
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var glowPulse: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Premium sun icon with animated glow
            ZStack {
                // Outer pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.goldenYellow.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(glowPulse)
                
                // Inner glow
                Circle()
                    .fill(AppColors.goldenYellow.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.goldenYellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: AppColors.goldenYellow.opacity(0.5), radius: 20)
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)
            
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("Affirm")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Start each day with positivity\nand purpose")
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(textOpacity)
            
            Spacer()
            
            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(AppColors.deepCoral)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .white.opacity(0.3), radius: 16, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .opacity(buttonOpacity)
            .padding(.horizontal, 34)
            .padding(.bottom, 55)
        }
        .onAppear {
            if reduceMotion {
                logoScale = 1.0
                logoOpacity = 1.0
                textOpacity = 1.0
                buttonOpacity = 1.0
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                    textOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                    buttonOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowPulse = 1.15
                }
            }
        }
    }
}
