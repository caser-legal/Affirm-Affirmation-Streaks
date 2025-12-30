import Foundation
import SwiftData

enum Mood: String, Codable, CaseIterable {
    case happy = "Happy"
    case calm = "Calm"
    case grateful = "Grateful"
    case motivated = "Motivated"
    case neutral = "Neutral"
    case anxious = "Anxious"
    case sad = "Sad"
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .calm: return "leaf"
        case .grateful: return "heart"
        case .motivated: return "flame"
        case .neutral: return "face.dashed"
        case .anxious: return "bolt.heart"
        case .sad: return "cloud.rain"
        }
    }
}

@Model
final class MoodEntry {
    var id: UUID
    var mood: String
    var affirmationID: UUID?
    var createdAt: Date
    
    var moodEnum: Mood {
        Mood(rawValue: mood) ?? .neutral
    }
    
    init(mood: Mood, affirmationID: UUID? = nil) {
        self.id = UUID()
        self.mood = mood.rawValue
        self.affirmationID = affirmationID
        self.createdAt = Date()
    }
}
