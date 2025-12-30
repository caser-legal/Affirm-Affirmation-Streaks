import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    var affirmationsViewedIDs: [UUID]
    var favoriteAdded: Bool
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.affirmationsViewedIDs = []
        self.favoriteAdded = false
    }
}
