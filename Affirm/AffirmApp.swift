import SwiftUI
import SwiftData

@main
struct AffirmApp: App {
    let container: ModelContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var iCloudSync = iCloudSyncManager.shared
    
    init() {
        do {
            let schema = Schema([Affirmation.self, UserStats.self, DailyLog.self, JournalEntry.self, MoodEntry.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
            
            // Listen for iCloud changes
            NotificationCenter.default.addObserver(
                forName: .iCloudDataChanged,
                object: nil,
                queue: .main
            ) { [container] _ in
                Task { @MainActor in
                    await AffirmApp.syncFromiCloud(container: container)
                }
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.clearNotifications()
                }
        }
    }
    
    @MainActor
    private static func syncFromiCloud(container: ModelContainer) async {
        let context = ModelContext(container)
        
        // Sync favorites
        let favoriteIDs = iCloudSyncManager.shared.getFavorites()
        let descriptor = FetchDescriptor<Affirmation>()
        if let allAffirmations = try? context.fetch(descriptor) {
            for affirmation in allAffirmations {
                affirmation.isFavorite = favoriteIDs.contains(affirmation.id)
            }
        }
        
        // Sync custom affirmations
        let customAffirmationsData = iCloudSyncManager.shared.getCustomAffirmations()
        for dict in customAffirmationsData {
            if let affirmation = Affirmation.fromDictionary(dict) {
                // Check if already exists
                let targetID = affirmation.id
                let existingDescriptor = FetchDescriptor<Affirmation>(
                    predicate: #Predicate<Affirmation> { item in item.id == targetID }
                )
                if let existing = try? context.fetch(existingDescriptor).first {
                    // Update existing
                    existing.text = affirmation.text
                    existing.category = affirmation.category
                } else {
                    // Insert new
                    context.insert(affirmation)
                }
            }
        }
        
        try? context.save()
    }
}
