import SwiftUI
import CoreSpotlight
import MobileCoreServices

// MARK: - Master Design System (Fibonacci Spacing)
enum DS {
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 13
        static let lg: CGFloat = 21
        static let xl: CGFloat = 34
        static let xxl: CGFloat = 55
        static let xxxl: CGFloat = 89
    }
    enum Typography {
        static let caption2: CGFloat = 11
        static let caption: CGFloat = 14
        static let body: CGFloat = 17
        static let title3: CGFloat = 21
        static let title2: CGFloat = 27
        static let title1: CGFloat = 34
    }
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 13
        static let lg: CGFloat = 21
        static let xl: CGFloat = 34
    }
    enum Touch {
        static let min: CGFloat = 44
    }
}

// MARK: - Animated Mesh Background (Visual System)
struct AnimatedMeshBackground: View {
    @State private var t: Float = 0.0
    let timer = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()
    let colors: [Color]
    
    init(colors: [Color] = [.blue, .purple, .indigo, .cyan, .blue, .purple, .indigo, .cyan, .blue]) {
        self.colors = colors
    }
    
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [sinInRange(-0.8...(-0.2), offset: 0.439, t: t), sinInRange(0.3...0.7, offset: 3.42, t: t)],
                [sinInRange(0.1...0.9, offset: 0.239, t: t), sinInRange(0.2...0.8, offset: 5.21, t: t)],
                [sinInRange(1.0...1.5, offset: 0.939, t: t), sinInRange(0.4...0.8, offset: 0.25, t: t)],
                [sinInRange(-0.8...0.0, offset: 1.439, t: t), sinInRange(1.4...1.9, offset: 3.42, t: t)],
                [sinInRange(0.3...0.6, offset: 0.339, t: t), sinInRange(1.0...1.2, offset: 1.22, t: t)],
                [sinInRange(1.0...1.5, offset: 0.939, t: t), sinInRange(1.0...1.3, offset: 0.47, t: t)]
            ],
            colors: colors
        )
        .ignoresSafeArea()
        .onReceive(timer) { _ in t += 0.01 }
    }
    
    private func sinInRange(_ range: ClosedRange<Float>, offset: Float, t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(t + offset)
    }
}

// MARK: - Liquid Glass Card (iOS 26 Style)
struct LiquidGlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DS.Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.lg).stroke(.white.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

// MARK: - Scale Button Style (Tactile Feedback)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: configuration.isPressed)
    }
}

// MARK: - Confetti View (Celebratory Feedback)
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: isAnimating ? geo.size.height + 50 : particle.y)
                        .opacity(isAnimating ? 0 : 1)
                        .rotationEffect(.degrees(isAnimating ? particle.rotation : 0))
                }
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 2.5)) { isAnimating = true }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles() {
        particles = (0..<40).map { i in
            ConfettiParticle(
                id: i,
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: -50...100),
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement()!,
                rotation: Double.random(in: 180...720)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
}

// MARK: - Tooltip View (Contextual Tips)
struct TooltipView: View {
    let text: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Tip")
                    .font(.caption.weight(.semibold))
                Spacer()
                Button { onDismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: DS.Touch.min, minHeight: DS.Touch.min)
            }
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(DS.Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DS.Radius.md))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.md).stroke(.white.opacity(0.2), lineWidth: 1))
        .shadow(radius: 5)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 55))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: DS.Typography.title3, weight: .bold, design: .rounded))
            Text(message)
                .font(.system(size: DS.Typography.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.xl)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: DS.Typography.body, weight: .semibold, design: .rounded))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Pro Feature Overlay (Monetization)
struct ProFeatureOverlay: View {
    let title: String
    let description: String
    let onUpgrade: () -> Void
    private let goldColor = Color(red: 1.0, green: 0.84, blue: 0.0)
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(goldColor)
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: animate)
            
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(description)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(goldColor)
                    Text("Upgrade to Pro")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(goldColor.opacity(0.15), in: RoundedRectangle(cornerRadius: DS.Radius.md))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DS.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear { animate = true }
    }
}

// MARK: - Keyboard Shortcuts Helper (iPad)
struct KeyboardShortcutsView: View {
    @Binding var selectedTab: Int
    @Binding var showCommandPalette: Bool
    let tabCount: Int
    
    init(selectedTab: Binding<Int>, showCommandPalette: Binding<Bool>, tabCount: Int = 5) {
        self._selectedTab = selectedTab
        self._showCommandPalette = showCommandPalette
        self.tabCount = tabCount
    }
    
    var body: some View {
        Group {
            if tabCount >= 1 { Button("") { selectedTab = 0 }.keyboardShortcut("1", modifiers: .command).hidden() }
            if tabCount >= 2 { Button("") { selectedTab = 1 }.keyboardShortcut("2", modifiers: .command).hidden() }
            if tabCount >= 3 { Button("") { selectedTab = 2 }.keyboardShortcut("3", modifiers: .command).hidden() }
            if tabCount >= 4 { Button("") { selectedTab = 3 }.keyboardShortcut("4", modifiers: .command).hidden() }
            if tabCount >= 5 { Button("") { selectedTab = 4 }.keyboardShortcut(",", modifiers: .command).hidden() }
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

// MARK: - Custom Pull to Refresh
struct CustomRefreshView: View {
    let isRefreshing: Bool
    
    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(0.8)
            }
            Text(isRefreshing ? "Refreshing..." : "Pull to refresh")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: 40)
    }
}

// MARK: - Destructive Alert Modifier
struct DestructiveAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let destructiveTitle: String
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button("Cancel", role: .cancel) { }
                Button(destructiveTitle, role: .destructive, action: onConfirm)
            } message: {
                Text(message)
            }
    }
}

extension View {
    func destructiveAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        destructiveTitle: String = "Delete",
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(DestructiveAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            destructiveTitle: destructiveTitle,
            onConfirm: onConfirm
        ))
    }
}

// MARK: - Spotlight Manager
class SpotlightManager {
    static let shared = SpotlightManager()
    
    func indexItems<T: Identifiable>(_ items: [T], domainIdentifier: String, titleKeyPath: KeyPath<T, String>, descriptionKeyPath: KeyPath<T, String>? = nil, keywords: [String] = []) {
        var searchableItems: [CSSearchableItem] = []
        
        for item in items {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
            attributeSet.title = item[keyPath: titleKeyPath]
            if let descPath = descriptionKeyPath {
                attributeSet.contentDescription = item[keyPath: descPath]
            }
            attributeSet.keywords = keywords
            
            let searchItem = CSSearchableItem(
                uniqueIdentifier: "\(domainIdentifier)-\(item.id)",
                domainIdentifier: domainIdentifier,
                attributeSet: attributeSet
            )
            searchableItems.append(searchItem)
        }
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                print("Spotlight indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    func deindexAll() {
        CSSearchableIndex.default().deleteAllSearchableItems { _ in }
    }
}

// MARK: - Money Font Extension
extension Font {
    static func money(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Monospaced Digit Text
struct MonospacedDigitText: View {
    let value: String
    let size: CGFloat
    let weight: Font.Weight
    
    init(_ value: String, size: CGFloat = 17, weight: Font.Weight = .regular) {
        self.value = value
        self.size = size
        self.weight = weight
    }
    
    init(_ number: Double, format: String = "%.2f", size: CGFloat = 17, weight: Font.Weight = .regular) {
        self.value = String(format: format, number)
        self.size = size
        self.weight = weight
    }
    
    var body: some View {
        Text(value)
            .font(.system(size: size, weight: weight, design: .rounded))
            .monospacedDigit()
    }
}
