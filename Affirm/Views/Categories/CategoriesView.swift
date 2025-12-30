import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query private var affirmations: [Affirmation]
    @AppStorage("selectedCategories") private var selectedCategoriesData: Data = Data()
    @State private var selectedCategories: Set<AffirmationCategory> = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 13),
        GridItem(.flexible(), spacing: 13)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 21) {
                    // Header card showing selection
                    if !selectedCategories.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(selectedCategories.count) selected")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Text("Tap to deselect")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategories.removeAll()
                                    saveSelection()
                                }
                            } label: {
                                Text("Clear All")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppColors.warmCoral, in: Capsule())
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // All Categories hero card
                    AllCategoriesCard(
                        isSelected: selectedCategories.isEmpty,
                        totalCount: affirmations.count,
                        onTap: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategories.removeAll()
                                saveSelection()
                            }
                        }
                    )
                    
                    // Category grid
                    LazyVGrid(columns: columns, spacing: 13) {
                        ForEach(AffirmationCategory.allCases) { category in
                            CategoryGridCard(
                                category: category,
                                count: affirmations.filter { $0.category == category }.count,
                                isSelected: selectedCategories.contains(category),
                                onTap: { toggleCategory(category) }
                            )
                        }
                    }
                }
                .padding(21)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Categories")
        }
        .onAppear { loadSelection() }
    }
    
    private func toggleCategory(_ category: AffirmationCategory) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3)) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
            saveSelection()
        }
    }
    
    private func saveSelection() {
        let rawValues = selectedCategories.map { $0.rawValue }
        selectedCategoriesData = (try? JSONEncoder().encode(rawValues)) ?? Data()
    }
    
    private func loadSelection() {
        if let rawValues = try? JSONDecoder().decode([String].self, from: selectedCategoriesData) {
            selectedCategories = Set(rawValues.compactMap { AffirmationCategory(rawValue: $0) })
        }
    }
}

struct AllCategoriesCard: View {
    let isSelected: Bool
    let totalCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.warmCoral, AppColors.sunsetOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("All Categories")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("\(totalCount) affirmations")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundStyle(isSelected ? AppColors.warmCoral : Color(.tertiaryLabel))
                    .symbolEffect(.bounce, value: isSelected)
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppColors.warmCoral : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("All categories, \(totalCount) affirmations")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct CategoryGridCard: View {
    let category: AffirmationCategory
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color : category.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(isSelected ? .white : category.color)
                        .symbolEffect(.bounce, value: isSelected)
                }
                
                VStack(spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("\(count)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : .clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(category.color)
                        .background(Circle().fill(Color(.secondarySystemGroupedBackground)).padding(-2))
                        .offset(x: -8, y: 8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(category.rawValue), \(count) affirmations")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
