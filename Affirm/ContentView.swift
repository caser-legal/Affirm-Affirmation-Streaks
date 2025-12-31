import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @Query private var affirmations: [Affirmation]
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
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
