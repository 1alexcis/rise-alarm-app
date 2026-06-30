import SwiftUI

/// Fully code-drawn sun character — no external image assets.
/// Scales to any CGFloat size. Animated rays via rotationEffect.
struct SunView: View {
    let expression: SunExpression
    let size: CGFloat

    @State private var rayRotation: Double = 0
    @State private var wavingOffset: CGFloat = 0

    private var rayCount: Int { 8 }
    private var raySpeed: Double {
        switch expression {
        case .celebrating: return 2.0
        case .happy:       return 5.0
        case .sleepy:      return 12.0
        case .sad:         return 20.0
        default:           return 8.0
        }
    }
    private var faceColor: Color {
        switch expression {
        case .sad:   return Rise.Color.textSecondary
        case .sleepy: return Rise.Color.primary.opacity(0.8)
        default:     return Rise.Color.primary
        }
    }

    var body: some View {
        ZStack {
            // Rotating rays layer
            raysView
                .rotationEffect(.degrees(rayRotation))
                .animation(
                    .linear(duration: raySpeed).repeatForever(autoreverses: false),
                    value: rayRotation
                )

            // Sun face circle
            Circle()
                .fill(faceColor)
                .frame(width: size * 0.6, height: size * 0.6)
                .shadow(color: Rise.Color.primary.opacity(0.4), radius: size * 0.08)

            // Face expression overlay
            faceOverlay
                .frame(width: size * 0.6, height: size * 0.6)
        }
        .frame(width: size, height: size)
        .onAppear {
            rayRotation = 360
        }
    }

    // MARK: - Rays
    private var raysView: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let innerR = size * 0.33
            let outerR = size * 0.48
            let rayWidth = size * 0.06

            for i in 0..<rayCount {
                let angle = Double(i) * (360.0 / Double(rayCount)) * .pi / 180
                let isWavingRay = (expression == .waving && i == 1)

                let innerX = center.x + cos(angle) * innerR
                let innerY = center.y + sin(angle) * innerR
                let tipX   = center.x + cos(angle) * (isWavingRay ? outerR * 1.2 : outerR)
                let tipY   = center.y + sin(angle) * (isWavingRay ? outerR * 1.2 : outerR)

                var path = Path()
                path.move(to: CGPoint(x: innerX, y: innerY))
                path.addLine(to: CGPoint(x: tipX, y: tipY))

                let strokeStyle = StrokeStyle(lineWidth: isWavingRay ? rayWidth * 1.3 : rayWidth,
                                              lineCap: .round)
                let color = expression == .sad
                    ? Rise.Color.textSecondary.opacity(0.6)
                    : Rise.Color.primary.opacity(0.7)
                context.stroke(path, with: .color(color), style: strokeStyle)
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Face expressions
    @ViewBuilder
    private var faceOverlay: some View {
        let eyeSize = size * 0.07
        let eyeY    = size * 0.6 * 0.28
        let eyeX    = size * 0.6 * 0.18

        switch expression {
        case .sleepy:
            // Half-closed eyes (horizontal lines)
            ZStack {
                Capsule().fill(Rise.Color.text)
                    .frame(width: eyeSize * 1.4, height: eyeSize * 0.5)
                    .offset(x: -eyeX, y: -eyeY)
                Capsule().fill(Rise.Color.text)
                    .frame(width: eyeSize * 1.4, height: eyeSize * 0.5)
                    .offset(x: eyeX, y: -eyeY)
                // Slight frown
                Arc(startAngle: .degrees(10), endAngle: .degrees(170), clockwise: true)
                    .stroke(Rise.Color.text, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
                    .frame(width: size * 0.22, height: size * 0.1)
                    .offset(y: size * 0.6 * 0.22)
            }

        case .sad:
            ZStack {
                Circle().fill(Rise.Color.text).frame(width: eyeSize, height: eyeSize)
                    .offset(x: -eyeX, y: -eyeY)
                Circle().fill(Rise.Color.text).frame(width: eyeSize, height: eyeSize)
                    .offset(x: eyeX, y: -eyeY)
                Arc(startAngle: .degrees(10), endAngle: .degrees(170), clockwise: true)
                    .stroke(Rise.Color.text, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
                    .frame(width: size * 0.22, height: size * 0.1)
                    .offset(y: size * 0.6 * 0.22)
            }

        case .celebrating, .happy:
            ZStack {
                // Arc eyes (happy squint)
                Arc(startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
                    .stroke(Rise.Color.text, style: StrokeStyle(lineWidth: size * 0.04, lineCap: .round))
                    .frame(width: eyeSize * 1.6, height: eyeSize)
                    .offset(x: -eyeX, y: -eyeY)
                Arc(startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
                    .stroke(Rise.Color.text, style: StrokeStyle(lineWidth: size * 0.04, lineCap: .round))
                    .frame(width: eyeSize * 1.6, height: eyeSize)
                    .offset(x: eyeX, y: -eyeY)
                // Big smile
                Arc(startAngle: .degrees(10), endAngle: .degrees(170), clockwise: false)
                    .stroke(Rise.Color.text, style: StrokeStyle(lineWidth: size * 0.04, lineCap: .round))
                    .frame(width: size * 0.28, height: size * 0.14)
                    .offset(y: size * 0.6 * 0.18)
            }

        default:
            // Neutral / waving — simple dot eyes + small smile
            ZStack {
                Circle().fill(Rise.Color.text).frame(width: eyeSize, height: eyeSize)
                    .offset(x: -eyeX, y: -eyeY)
                Circle().fill(Rise.Color.text).frame(width: eyeSize, height: eyeSize)
                    .offset(x: eyeX, y: -eyeY)
                Arc(startAngle: .degrees(10), endAngle: .degrees(170), clockwise: false)
                    .stroke(Rise.Color.text, style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round))
                    .frame(width: size * 0.22, height: size * 0.1)
                    .offset(y: size * 0.6 * 0.18)
            }
        }
    }
}

// MARK: - Arc helper shape
private struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: clockwise)
        return path
    }
}

#Preview {
    HStack(spacing: 12) {
        SunView(expression: .happy, size: 80)
        SunView(expression: .sleepy, size: 80)
        SunView(expression: .sad, size: 80)
        SunView(expression: .celebrating, size: 80)
        SunView(expression: .waving, size: 80)
    }
    .padding()
    .background(Rise.Color.background)
}
