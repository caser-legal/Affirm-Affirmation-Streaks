import SwiftUI

enum AffirmationCategory: String, Codable, CaseIterable, Identifiable {
    case selfLove = "Self-Love"
    case confidence = "Confidence"
    case gratitude = "Gratitude"
    case success = "Success"
    case health = "Health"
    case relationships = "Relationships"
    case morning = "Morning"
    case evening = "Evening"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .selfLove: return "heart.fill"
        case .confidence: return "star.fill"
        case .gratitude: return "hands.clap.fill"
        case .success: return "trophy.fill"
        case .health: return "leaf.fill"
        case .relationships: return "person.2.fill"
        case .morning: return "sunrise.fill"
        case .evening: return "moon.stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .selfLove: return Color(hex: "FF6B6B")
        case .confidence: return Color(hex: "FFD93D")
        case .gratitude: return Color(hex: "6BCB77")
        case .success: return Color(hex: "4D96FF")
        case .health: return Color(hex: "9B59B6")
        case .relationships: return Color(hex: "FF8C42")
        case .morning: return Color(hex: "FFA07A")
        case .evening: return Color(hex: "5D5FEF")
        }
    }
    
    var cardGradient: LinearGradient {
        switch self {
        case .selfLove:
            return LinearGradient(colors: [Color(hex: "FFF5F5"), Color(hex: "FFE8E8")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .confidence:
            return LinearGradient(colors: [Color(hex: "FFFDF5"), Color(hex: "FFF8E1")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gratitude:
            return LinearGradient(colors: [Color(hex: "F5FFF7"), Color(hex: "E8F5E9")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .success:
            return LinearGradient(colors: [Color(hex: "F5F9FF"), Color(hex: "E3F2FD")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .health:
            return LinearGradient(colors: [Color(hex: "FAF5FF"), Color(hex: "F3E5F5")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .relationships:
            return LinearGradient(colors: [Color(hex: "FFF8F5"), Color(hex: "FFF3E0")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .morning:
            return LinearGradient(colors: [Color(hex: "FFFAF5"), Color(hex: "FFE0B2")], startPoint: .top, endPoint: .bottom)
        case .evening:
            return LinearGradient(colors: [Color(hex: "F5F5FF"), Color(hex: "E8EAF6")], startPoint: .top, endPoint: .bottom)
        }
    }
}
