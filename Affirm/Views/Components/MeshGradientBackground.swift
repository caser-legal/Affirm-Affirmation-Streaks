import SwiftUI

struct MeshGradientBackground: View {
    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.warmCoral,
                    AppColors.salmonPink,
                    AppColors.sunsetOrange,
                    AppColors.warmCoral
                ],
                startPoint: animate ? .topLeading : .topTrailing,
                endPoint: animate ? .bottomTrailing : .bottomLeading
            )
            .ignoresSafeArea()
            
            if !reduceMotion {
                SparkleParticlesView()
            }
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }
}

struct SparkleParticlesView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<12, id: \.self) { i in
                SparkleParticle(
                    size: CGFloat(8 + (i % 4) * 3),
                    xPos: geo.size.width * CGFloat(i % 4 + 1) / 5,
                    yPos: geo.size.height * CGFloat(i / 4 + 1) / 5,
                    delay: Double(i) * 0.3
                )
            }
        }
    }
}

struct SparkleParticle: View {
    let size: CGFloat
    let xPos: CGFloat
    let yPos: CGFloat
    let delay: Double
    
    @State private var opacity: Double = 0.3
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundStyle(.white.opacity(opacity))
            .position(x: xPos, y: yPos)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(delay)) {
                    opacity = 0.8
                }
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false).delay(delay)) {
                    yOffset = -80
                }
            }
    }
}
