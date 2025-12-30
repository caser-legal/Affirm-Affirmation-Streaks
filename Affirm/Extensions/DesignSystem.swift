import SwiftUI

struct AppColors {
    static let warmCoral = Color(hex: "FF6B6B")
    static let sunsetOrange = Color(hex: "FF8C42")
    static let goldenYellow = Color(hex: "FFD93D")
    static let salmonPink = Color(hex: "FFA07A")
    static let deepCoral = Color(hex: "E85D5D")
    
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
}

struct AppFonts {
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    
    // Dynamic Type supporting fonts
    static func dynamicRounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded, weight: weight)
    }
}

// Button style with pressed state
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Text field style with focus state
struct FocusedTextFieldStyle: ViewModifier {
    let isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? AppColors.warmCoral : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

extension View {
    func focusedStyle(_ isFocused: Bool) -> some View {
        modifier(FocusedTextFieldStyle(isFocused: isFocused))
    }
}

// MARK: - Keyboard Shortcuts View (iPad)
struct KeyboardShortcutsView: View {
    @Binding var selectedTab: Int
    @Binding var showCommandPalette: Bool
    let tabCount: Int
    
    var body: some View {
        Group {
            if tabCount >= 1 { Button("") { selectedTab = 0 }.keyboardShortcut("1", modifiers: .command).hidden() }
            if tabCount >= 2 { Button("") { selectedTab = 1 }.keyboardShortcut("2", modifiers: .command).hidden() }
            if tabCount >= 3 { Button("") { selectedTab = 2 }.keyboardShortcut("3", modifiers: .command).hidden() }
            if tabCount >= 4 { Button("") { selectedTab = 3 }.keyboardShortcut(",", modifiers: .command).hidden() }
            Button("") { showCommandPalette = true }.keyboardShortcut("k", modifiers: .command).hidden()
        }
    }
}

// MARK: - Sidebar Resize Handle (iPad)
struct SidebarResizeHandle: View {
    @Binding var width: CGFloat
    @GestureState private var isDragging = false
    
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(isDragging ? 0.5 : 0.001))
            .frame(width: 6)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in state = true }
                    .onChanged { value in
                        let newWidth = width + value.translation.width
                        width = min(max(200, newWidth), 400)
                    }
            )
    }
}

// MARK: - MainView Alias
typealias MainView = HomeView
