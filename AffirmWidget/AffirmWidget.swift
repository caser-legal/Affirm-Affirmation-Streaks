import WidgetKit
import SwiftUI

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
    let category: String
    let streak: Int
    let additionalAffirmations: [String]
}

struct Provider: TimelineProvider {
    private let affirmations = [
        ("I am worthy of love and respect", "Self-Love"),
        ("I believe in my abilities", "Confidence"),
        ("I am grateful for this moment", "Gratitude"),
        ("Success flows to me naturally", "Success"),
        ("My body is healthy and strong", "Health"),
        ("I attract positive relationships", "Relationships"),
        ("Today is full of possibilities", "Morning"),
        ("I release the day with peace", "Evening")
    ]
    
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: Date(), affirmation: "I am worthy of love and respect", category: "Self-Love", streak: 7, additionalAffirmations: ["I believe in myself", "Today is a gift"])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let entry = AffirmationEntry(date: Date(), affirmation: affirmations[0].0, category: affirmations[0].1, streak: UserDefaults(suiteName: "group.com.affirm.app")?.integer(forKey: "currentStreak") ?? 0, additionalAffirmations: [affirmations[1].0, affirmations[2].0])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        let dayIndex = Calendar.current.component(.day, from: Date()) % affirmations.count
        let selected = affirmations[dayIndex]
        let streak = UserDefaults(suiteName: "group.com.affirm.app")?.integer(forKey: "currentStreak") ?? 0
        let additional = [affirmations[(dayIndex + 1) % affirmations.count].0, affirmations[(dayIndex + 2) % affirmations.count].0]
        
        let entry = AffirmationEntry(date: Date(), affirmation: selected.0, category: selected.1, streak: streak, additionalAffirmations: additional)
        
        let nextUpdate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SmallWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.55, blue: 0.26)], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            Text(entry.affirmation)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(12)
        }
    }
}

struct MediumWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.55, blue: 0.26)], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.category)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                
                Text(entry.affirmation)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                
                Spacer()
                
                Text(entry.date, style: .date)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(13)
        }
    }
}

struct LargeWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.55, blue: 0.26)], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(entry.category)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(entry.streak)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
                
                Text(entry.affirmation)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(4)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(entry.additionalAffirmations, id: \.self) { text in
                        Text(text)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                    }
                }
                
                Text(entry.date, style: .date)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(13)
        }
    }
}

struct AffirmWidget: Widget {
    let kind: String = "AffirmWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AffirmWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AffirmWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Daily Affirmation")
        .description("Start your day with positivity")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct AffirmWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: AffirmationEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

@main
struct AffirmWidgetBundle: WidgetBundle {
    var body: some Widget {
        AffirmWidget()
    }
}
