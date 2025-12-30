import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @State private var showCommandPalette = false
    @State private var sidebarWidth: CGFloat = 280
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool { horizontalSizeClass == .regular }
    
    var body: some View {
        Group {
            if isIPad { iPadLayout } else { iPhoneLayout }
        }
        .sheet(isPresented: $showCommandPalette) {
            AffirmCommandPalette(selectedTab: $selectedTab)
        }
        .background(KeyboardShortcutsView(selectedTab: $selectedTab, showCommandPalette: $showCommandPalette, tabCount: 2))
    }
    
    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(1)
        }
    }
    
    private var iPadLayout: some View {
        HStack(spacing: 0) {
            NavigationStack {
                List {
                    Section {
                        AffirmSidebarButton(title: "Home", icon: "house", tag: 0, selected: $selectedTab)
                        AffirmSidebarButton(title: "Settings", icon: "gear", tag: 1, selected: $selectedTab)
                    }
                    Section("Quick Actions") {
                        Button { showCommandPalette = true } label: {
                            Label("Command Palette (⌘K)", systemImage: "command")
                        }
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Affirm")
            }
            .frame(width: sidebarWidth)
            
            SidebarResizeHandle(width: $sidebarWidth)
            
            ZStack {
                switch selectedTab {
                case 0: MainView()
                case 1: SettingsView()
                default: MainView()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct AffirmSidebarButton: View {
    let title: String
    let icon: String
    let tag: Int
    @Binding var selected: Int
    
    var body: some View {
        Button { selected = tag } label: {
            Label(title, systemImage: icon)
                .foregroundStyle(selected == tag ? Color.accentColor : .primary)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct AffirmCommandPalette: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Quick Actions") {
                    Button { selectedTab = 0; dismiss() } label: {
                        Label("Go to Home", systemImage: "house")
                    }
                    Button { selectedTab = 1; dismiss() } label: {
                        Label("Go to Settings", systemImage: "gear")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search...")
            .navigationTitle("Command Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
