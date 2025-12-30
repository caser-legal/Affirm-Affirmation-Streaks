import Foundation
import SwiftData

@Model
final class UserStats {
    var id: UUID
    var currentStreak: Int
    var longestStreak: Int
    var totalAffirmationsViewed: Int
    var lastActiveDate: Date
    var favoriteCategoryRaw: String?
    
    var favoriteCategory: AffirmationCategory? {
        get { favoriteCategoryRaw.flatMap { AffirmationCategory(rawValue: $0) } }
        set { favoriteCategoryRaw = newValue?.rawValue }
    }
    
    init() {
        self.id = UUID()
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalAffirmationsViewed = 0
        self.lastActiveDate = Date()
        self.favoriteCategoryRaw = nil
    }
}
