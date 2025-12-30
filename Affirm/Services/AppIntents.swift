import AppIntents
import SwiftUI

struct GetDailyAffirmationIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Daily Affirmation"
    static let description = IntentDescription("Returns today's affirmation")
    static let openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let affirmations = [
            "I am worthy of love and respect",
            "I believe in my abilities and trust my journey",
            "I am grateful for all the blessings in my life",
            "Success flows to me naturally and effortlessly",
            "My body is healthy, strong, and full of energy",
            "I attract positive and loving relationships",
            "Today is full of endless possibilities",
            "I release the day with peace and gratitude"
        ]
        
        let dayIndex = Calendar.current.component(.day, from: Date()) % affirmations.count
        let affirmation = affirmations[dayIndex]
        
        return .result(value: affirmation, dialog: IntentDialog(stringLiteral: affirmation))
    }
}

struct AffirmShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetDailyAffirmationIntent(),
            phrases: [
                "Get my \(.applicationName) affirmation",
                "Daily affirmation from \(.applicationName)",
                "What's my affirmation in \(.applicationName)"
            ],
            shortTitle: "Daily Affirmation",
            systemImageName: "heart.fill"
        )
    }
}
