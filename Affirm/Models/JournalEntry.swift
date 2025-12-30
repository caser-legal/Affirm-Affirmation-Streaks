import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var affirmationID: UUID
    var text: String
    var createdAt: Date
    var updatedAt: Date
    
    init(affirmationID: UUID, text: String) {
        self.id = UUID()
        self.affirmationID = affirmationID
        self.text = text
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
