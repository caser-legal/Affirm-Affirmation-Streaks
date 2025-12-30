import SwiftUI

struct AffirmationCard: View {
    let affirmation: Affirmation
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var speechManager = SpeechManager.shared
    @State private var showJournal = false
    
    private var cardHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 500 : 420
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(affirmation.text)
                .font(AppFonts.dynamicRounded(.title2, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 28)
            
            Spacer()
            
            HStack(spacing: 4) {
                MoodButton(affirmationID: affirmation.id)
                JournalButton(showJournal: $showJournal)
                AudioButton(text: affirmation.text)
                ShareButton(text: affirmation.text, category: affirmation.category)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 320, height: cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(affirmation.category.cardGradient)
                .shadow(color: affirmation.category.color.opacity(0.3), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.goldenYellow, AppColors.goldenYellow.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        )
        .shadow(color: AppColors.goldenYellow.opacity(0.35), radius: 24, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(affirmation.text). Category: \(affirmation.category.rawValue)")
        .accessibilityHint("Double tap to favorite. Swipe left or right to see more affirmations.")
        .sheet(isPresented: $showJournal) {
        // TODO: Modal needs dismiss path. Add @Environment(\.dismiss) or Button("Done") { showJournal = false }
            JournalView(affirmation: affirmation)
        }
    }
}

struct JournalButton: View {
    @Binding var showJournal: Bool
    
    var body: some View {
        Button(action: { showJournal = true }) {
            Image(systemName: "book.closed")
                .font(.system(size: 18))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Open journal")
    }
}

struct MoodButton: View {
    let affirmationID: UUID
    @State private var showMoodPicker = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button(action: { showMoodPicker = true }) {
            Image(systemName: "face.smiling")
                .font(.system(size: 18))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Open mood picker")
        .confirmationDialog("How are you feeling?", isPresented: $showMoodPicker) {
            ForEach(Mood.allCases, id: \.self) { mood in
                Button(mood.rawValue) {
                    let entry = MoodEntry(mood: mood, affirmationID: affirmationID)
                    modelContext.insert(entry)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}

struct CategoryBadge: View {
    let category: AffirmationCategory
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 12, weight: .medium))
            Text(category.rawValue)
                .font(AppFonts.dynamicRounded(.footnote, weight: .semibold))
        }
        .foregroundStyle(category.color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(category.color.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(category.color.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityLabel("\(category.rawValue) category")
    }
}

struct AudioButton: View {
    let text: String
    @StateObject private var speechManager = SpeechManager.shared
    
    var body: some View {
        Button(action: { speechManager.speak(text) }) {
            Image(systemName: speechManager.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.system(size: 18))
                .foregroundStyle(speechManager.isSpeaking ? AppColors.warmCoral : AppColors.textSecondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(speechManager.isSpeaking ? "Stop reading" : "Read aloud")
    }
}

struct ShareButton: View {
    let text: String
    let category: AffirmationCategory
    @AppStorage("showShareOptions") private var showShareOptions = false
    
    var body: some View {
        Button(action: { showShareOptions = true }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Open share options")
        .confirmationDialog("Share", isPresented: $showShareOptions) {
            ShareLink(item: text) {
                Text("Share as Text")
            }
            ShareLink(item: ShareableCardImage(text: text, category: category), preview: SharePreview("Affirmation", image: ShareableCardImage(text: text, category: category))) {
                Text("Share as Image")
            }
        }
    }
}

struct ShareableCardImage: Transferable {
    let text: String
    let category: AffirmationCategory
    
    @MainActor func renderImage() -> Image {
        let renderer = ImageRenderer(content: ShareableCardView(text: text, category: category))
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }
    
    @MainActor func renderPNGData() -> Data {
        let renderer = ImageRenderer(content: ShareableCardView(text: text, category: category))
        renderer.scale = 3.0
        return renderer.uiImage?.pngData() ?? Data()
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            await item.renderPNGData()
        }
    }
}

struct ShareableCardView: View {
    let text: String
    let category: AffirmationCategory
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(text)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())
            
            Text("Affirm")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(32)
        .frame(width: 400, height: 500)
        .background(
            LinearGradient(
                colors: [AppColors.warmCoral, AppColors.sunsetOrange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
