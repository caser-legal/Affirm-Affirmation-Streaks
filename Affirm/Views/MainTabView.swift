import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @Namespace private var animation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "rectangle.stack.fill")
                }
                .tag(0)
                .accessibilityLabel("Home tab, affirmation cards")
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(1)
                .accessibilityLabel("Favorites tab, saved affirmations")
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)
                .accessibilityLabel("Categories tab, filter by category")
            
            CreateView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(3)
                .accessibilityLabel("Create tab, make your own affirmation")
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
                .accessibilityLabel("Settings tab, app preferences")
        }
        .tint(AppColors.warmCoral)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}
