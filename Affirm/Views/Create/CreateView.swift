import SwiftUI
import SwiftData

struct CreateView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Affirmation> { $0.isCustom }) private var customAffirmations: [Affirmation]
    
    @State private var text = ""
    @State private var selectedCategory: AffirmationCategory = .selfLove
    @State private var showSuccess = false
    @State private var editingAffirmation: Affirmation?
    @FocusState private var isTextFocused: Bool
    
    private let maxCharacters = 200
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Input card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(editingAffirmation != nil ? "Edit Affirmation" : "Write Your Affirmation")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Spacer()
                            if editingAffirmation != nil {
                                Button("Cancel") {
                                    cancelEdit()
                                }
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.warmCoral)
                            }
                        }
                        
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("I am worthy of love and happiness...")
                                    .font(.system(size: 17, design: .rounded))
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            
                            TextEditor(text: $text)
                                .font(.system(size: 17, design: .rounded))
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                                .focused($isTextFocused)
                                .onChange(of: text) { _, newValue in
                                    if newValue.count > maxCharacters {
                                        text = String(newValue.prefix(maxCharacters))
                                    }
                                }
                        }
                        
                        HStack {
                            Spacer()
                            Text("\(text.count)/\(maxCharacters)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(text.count > maxCharacters - 20 ? AppColors.warmCoral : Color.gray.opacity(0.5))
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                    
                    // Category selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose a Category")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(AffirmationCategory.allCases) { category in
                                    CategoryChip(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        onTap: { selectedCategory = category }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Preview
                    if !text.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            PreviewCard(text: text, category: selectedCategory)
                        }
                    }
                    
                    // Save button
                    Button(action: saveAffirmation) {
                        HStack(spacing: 8) {
                            Image(systemName: editingAffirmation != nil ? "checkmark.circle.fill" : "plus.circle.fill")
                                .font(.system(size: 18))
                            Text(editingAffirmation != nil ? "Update" : "Save Affirmation")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            text.isEmpty ? AppColors.warmCoral.opacity(0.4) : AppColors.warmCoral,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(text.isEmpty)
                    
                    // Custom affirmations list
                    if !customAffirmations.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Your Affirmations")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Spacer()
                                Text("\(customAffirmations.count)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppColors.warmCoral, in: Capsule())
                            }
                            
                            ForEach(customAffirmations) { affirmation in
                                CustomAffirmationRow(
                                    affirmation: affirmation,
                                    onEdit: { startEditing(affirmation) },
                                    onDelete: { deleteAffirmation(affirmation) }
                                )
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        EmptyCustomView()
                            .padding(.top, 21)
                    }
                }
                .padding(21)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Create")
            .scrollDismissesKeyboard(.interactively)
            .overlay {
                if showSuccess {
                    SuccessToast()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private func saveAffirmation() {
        if let editing = editingAffirmation {
            editing.text = text
            editing.category = selectedCategory
            editingAffirmation = nil
        } else {
            let affirmation = Affirmation(text: text, category: selectedCategory, isCustom: true)
            modelContext.insert(affirmation)
        }
        text = ""
        isTextFocused = false
        
        let customAffirmationsData = customAffirmations.map { $0.toDictionary() }
        if SubscriptionManager.shared.isPro {
            iCloudSyncManager.shared.syncCustomAffirmations(customAffirmationsData)
        }
        
        withAnimation(.spring(response: 0.3)) {
            showSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showSuccess = false }
        }
    }
    
    private func startEditing(_ affirmation: Affirmation) {
        editingAffirmation = affirmation
        text = affirmation.text
        selectedCategory = affirmation.category
    }
    
    private func cancelEdit() {
        editingAffirmation = nil
        text = ""
        selectedCategory = .selfLove
        isTextFocused = false
    }
    
    private func deleteAffirmation(_ affirmation: Affirmation) {
        modelContext.delete(affirmation)
        if SubscriptionManager.shared.isPro {
            let customAffirmationsData = customAffirmations.filter { $0.id != affirmation.id }.map { $0.toDictionary() }
            iCloudSyncManager.shared.syncCustomAffirmations(customAffirmationsData)
        }
    }
}

struct CategoryChip: View {
    let category: AffirmationCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundStyle(isSelected ? .white : category.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ? category.color : category.color.opacity(0.12),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? .clear : category.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(category.rawValue) category")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct PreviewCard: View {
    let text: String
    let category: AffirmationCategory
    
    var body: some View {
        VStack(spacing: 16) {
            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            CategoryBadge(category: category)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(category.cardGradient, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.goldenYellow, lineWidth: 2)
        )
        .shadow(color: AppColors.goldenYellow.opacity(0.25), radius: 16, y: 6)
    }
}

struct CustomAffirmationRow: View {
    let affirmation: Affirmation
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete background
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                }
                .accessibilityLabel("Delete affirmation")
            }
            .background(.red.gradient, in: RoundedRectangle(cornerRadius: 16))
            
            // Main content
            HStack(spacing: 12) {
                Circle()
                    .fill(affirmation.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: affirmation.category.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(affirmation.category.color)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(affirmation.text)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Text(affirmation.category.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(affirmation.category.color)
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppColors.warmCoral.opacity(0.8))
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("Edit affirmation")
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3)) {
                            if value.translation.width < -50 {
                                offset = -70
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) { offset = 0 }
            }
        }
    }
}

struct EmptyCustomView: View {
    @State private var sparkleRotation: Double = 0
    @State private var glowOpacity: Double = 0.2
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.warmCoral.opacity(glowOpacity), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(AppColors.warmCoral.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 88, height: 88)
                
                Circle()
                    .fill(AppColors.warmCoral.opacity(0.08))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(AppColors.warmCoral)
                    .rotationEffect(.degrees(sparkleRotation))
            }
            
            VStack(spacing: 8) {
                Text("No Custom Affirmations")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("Create your first one above")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.4
            }
        }
    }
}

struct SuccessToast: View {
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.green)
                Text("Saved!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
            
            Spacer()
        }
        .padding(.top, 60)
    }
}
