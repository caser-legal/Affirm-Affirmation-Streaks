import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appearanceMode") private var appearanceMode = 0
    @Environment(\.modelContext) private var modelContext
    @Query private var affirmations: [Affirmation]
    
    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case 1: return .light
        case 2: return .dark
        default: return nil // System
        }
    }
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(colorScheme)
        .onAppear {
            seedAffirmationsIfNeeded()
        }
    }
    
    private func seedAffirmationsIfNeeded() {
        // Only seed if no affirmations exist
        if affirmations.isEmpty {
            AffirmationSeeder.seedAffirmations(context: modelContext)
        }
    }
}
