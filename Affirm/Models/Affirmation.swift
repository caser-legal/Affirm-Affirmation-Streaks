import Foundation
import SwiftData

@Model
final class Affirmation {
    var id: UUID
    var text: String
    var categoryRaw: String
    var isFavorite: Bool
    var isCustom: Bool
    var createdAt: Date
    var lastShownAt: Date?
    
    var category: AffirmationCategory {
        get { AffirmationCategory(rawValue: categoryRaw) ?? .selfLove }
        set { categoryRaw = newValue.rawValue }
    }
    
    init(text: String, category: AffirmationCategory, isCustom: Bool = false) {
        self.id = UUID()
        self.text = text
        self.categoryRaw = category.rawValue
        self.isFavorite = false
        self.isCustom = isCustom
        self.createdAt = Date()
        self.lastShownAt = nil
    }
    
    // MARK: - iCloud Sync Helpers
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "text": text,
            "category": categoryRaw,
            "isCustom": isCustom,
            "isFavorite": isFavorite,
            "createdAt": createdAt.timeIntervalSince1970
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Affirmation? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let text = dict["text"] as? String,
              let categoryString = dict["category"] as? String,
              let category = AffirmationCategory(rawValue: categoryString),
              let isCustom = dict["isCustom"] as? Bool,
              let isFavorite = dict["isFavorite"] as? Bool,
              let createdAtInterval = dict["createdAt"] as? TimeInterval else {
            return nil
        }
        
        let affirmation = Affirmation(text: text, category: category, isCustom: isCustom)
        affirmation.id = id
        affirmation.isFavorite = isFavorite
        affirmation.createdAt = Date(timeIntervalSince1970: createdAtInterval)
        return affirmation
    }
}
