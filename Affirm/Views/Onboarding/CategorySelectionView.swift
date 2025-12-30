import SwiftUI

struct CategorySelectionView: View {
    @Binding var selectedCategories: Set<AffirmationCategory>
    let onContinue: () -> Void
    @AppStorage("selectedCategories") private var selectedCategoriesData: Data = Data()
    
    private let columns = [
        GridItem(.flexible(), spacing: 13),
        GridItem(.flexible(), spacing: 13)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Text("Choose Your Focus")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Select the areas you want to grow in")
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.top, 34)
            .padding(.bottom, 21)
            
            // Selection counter
            if !selectedCategories.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(selectedCategories.prefix(4)), id: \.self) { category in
                        Image(systemName: category.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(category.color, in: Circle())
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    if selectedCategories.count > 4 {
                        Text("+\(selectedCategories.count - 4)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(.white.opacity(0.2), in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white.opacity(0.15), in: Capsule())
                .animation(.spring(response: 0.3), value: selectedCategories.count)
                .padding(.bottom, 21)
            }
            
            // Category grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 13) {
                    ForEach(AffirmationCategory.allCases) { category in
                        OnboardingCategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category),
                            onTap: {
                                toggleCategory(category)
                            }
                        )
                    }
                }
                .padding(.horizontal, 21)
                .padding(.bottom, 120)
            }
            
            Spacer(minLength: 0)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Button(action: {
                    saveSelection()
                    onContinue()
                }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(selectedCategories.isEmpty ? .gray : AppColors.deepCoral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(selectedCategories.isEmpty ? Color.white.opacity(0.5) : .white, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: selectedCategories.isEmpty ? .clear : .white.opacity(0.3), radius: 12, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(selectedCategories.isEmpty)
                
                if selectedCategories.isEmpty {
                    Text("Select at least one category")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 34)
            .padding(.bottom, 34)
            .background(
                LinearGradient(
                    colors: [.clear, AppColors.warmCoral.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private func toggleCategory(_ category: AffirmationCategory) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
    }
    
    private func saveSelection() {
        let rawValues = selectedCategories.map { $0.rawValue }
        selectedCategoriesData = (try? JSONEncoder().encode(rawValues)) ?? Data()
    }
}

struct OnboardingCategoryCard: View {
    let category: AffirmationCategory
    let isSelected: Bool
    let onTap: () -> Void
    @AppStorage("isPressed") private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                ZStack {
                    // Glow effect when selected
                    if isSelected {
                        Circle()
                            .fill(category.color.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .blur(radius: 8)
                    }
                    
                    Circle()
                        .fill(isSelected ? category.color : .white.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(isSelected ? .white : category.color)
                        .symbolEffect(.bounce, value: isSelected)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color.opacity(0.25) : .white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : .white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                        .background(Circle().fill(category.color).padding(-2))
                        .offset(x: -10, y: 10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(category.rawValue) category")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Double tap to deselect" : "Double tap to select")
    }
}
