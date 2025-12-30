import Foundation
import SwiftData
import UIKit
import UserNotifications

@MainActor
class StreakManager {
    static let shared = StreakManager()
    private let calendar = Calendar.current
    
    func recordActivity(context: ModelContext) {
        let stats = getOrCreateStats(context: context)
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: stats.lastActiveDate)
        
        // Already recorded today
        if calendar.isDate(today, inSameDayAs: lastActive) {
            return
        }
        
        let daysSinceLastActive = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0
        
        if daysSinceLastActive == 1 {
            // Consecutive day - increment streak
            stats.currentStreak += 1
        } else if daysSinceLastActive > 1 {
            // Missed days - reset streak
            stats.currentStreak = 1
        } else if stats.currentStreak == 0 {
            // First time
            stats.currentStreak = 1
        }
        
        // Update longest streak
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
        
        stats.lastActiveDate = Date()
        
        // Create daily log
        let log = DailyLog(date: today)
        context.insert(log)
        
        try? context.save()
    }
    
    func recordAffirmationViewed(affirmationID: UUID, context: ModelContext) {
        let stats = getOrCreateStats(context: context)
        stats.totalAffirmationsViewed += 1
        
        // Get or create today's log
        let today = calendar.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyLog>()
        let logs = (try? context.fetch(descriptor)) ?? []
        
        if let todayLog = logs.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            if !todayLog.affirmationsViewedIDs.contains(affirmationID) {
                todayLog.affirmationsViewedIDs.append(affirmationID)
            }
        }
        
        try? context.save()
    }
    
    func updateFavoriteCategory(context: ModelContext) {
        let stats = getOrCreateStats(context: context)
        let descriptor = FetchDescriptor<Affirmation>(predicate: #Predicate { $0.isFavorite })
        guard let favorites = try? context.fetch(descriptor), !favorites.isEmpty else { return }
        
        // Count favorites by category
        var categoryCounts: [String: Int] = [:]
        for fav in favorites {
            categoryCounts[fav.categoryRaw, default: 0] += 1
        }
        
        // Find most common category
        if let topCategory = categoryCounts.max(by: { $0.value < $1.value })?.key {
            stats.favoriteCategoryRaw = topCategory
        }
        
        try? context.save()
    }
    
    func getOrCreateStats(context: ModelContext) -> UserStats {
        let descriptor = FetchDescriptor<UserStats>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let newStats = UserStats()
        context.insert(newStats)
        return newStats
    }
}
