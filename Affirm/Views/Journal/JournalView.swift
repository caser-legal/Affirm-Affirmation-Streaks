import SwiftUI
import SwiftData

struct JournalView: View {
    let affirmation: Affirmation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [JournalEntry]
    @State private var text = ""
    @State private var showSaved = false
    @FocusState private var isFocused: Bool
    
    private var existingEntry: JournalEntry? {
        entries.first { $0.affirmationID == affirmation.id }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium gradient background
                LinearGradient(
                    colors: [
                        affirmation.category.color.opacity(0.08),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Affirmation prompt card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(affirmation.category.color.opacity(0.12))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(affirmation.category.color)
                            }
                            
                            Text(affirmation.text)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            HStack(spacing: 6) {
                                Image(systemName: affirmation.category.icon)
                                    .font(.system(size: 12))
                                Text(affirmation.category.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(affirmation.category.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(affirmation.category.color.opacity(0.12), in: Capsule())
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(affirmation.category.cardGradient)
                                .shadow(color: affirmation.category.color.opacity(0.15), radius: 12, y: 6)
                        )
                        
                        // Journal entry section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.warmCoral)
                                Text("Your Reflection")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if text.isEmpty {
                                    Text("How does this affirmation make you feel? What thoughts come to mind?")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 16)
                                        .padding(.leading, 16)
                                }
                                
                                TextEditor(text: $text)
                                    .font(.system(size: 16, design: .rounded))
                                    .frame(minHeight: 180)
                                    .scrollContentBackground(.hidden)
                                    .padding(12)
                                    .focused($isFocused)
                            }
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isFocused ? AppColors.warmCoral : Color.clear, lineWidth: 2)
                            )
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            if existingEntry != nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12))
                                    Text("Last updated \(existingEntry!.updatedAt, style: .relative) ago")
                                        .font(.system(size: 13, design: .rounded))
                                }
                                .foregroundStyle(.tertiary)
                            }
                        }
                        
                        // Save button
                        Button(action: saveEntry) {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Save Reflection")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                text.isEmpty ? AppColors.warmCoral.opacity(0.4) : AppColors.warmCoral,
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .shadow(color: text.isEmpty ? .clear : AppColors.warmCoral.opacity(0.3), radius: 8, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(text.isEmpty)
                    }
                    .padding(21)
                }
                .scrollDismissesKeyboard(.interactively)
                
                // Success toast
                if showSaved {
                    VStack {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.green)
                            Text("Reflection Saved")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(.tertiaryLabel), Color(.quaternarySystemFill))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel("Close journal")
                }
            }
            .onAppear {
                if let entry = existingEntry {
                    text = entry.text
                }
            }
        }
    }
    
    private func saveEntry() {
        if let entry = existingEntry {
            entry.text = text
            entry.updatedAt = Date()
        } else {
            let entry = JournalEntry(affirmationID: affirmation.id, text: text)
            modelContext.insert(entry)
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.3)) {
            showSaved = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showSaved = false }
            dismiss()
        }
    }
}
