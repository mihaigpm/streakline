import SwiftUI

/// One-shot confetti burst rendered with Canvas. Non-interactive;
/// the parent should remove it after ~1.5 seconds.
struct ConfettiView: View {
    private struct Particle {
        let start: CGPoint
        let velocity: CGVector
        let size: CGFloat
        let spin: Double
        let color: Color
    }

    private let particles: [Particle]
    private let startDate = Date.now

    init(count: Int = 90) {
        let palette = [
            DesignSystem.Colors.teal,
            DesignSystem.Colors.amber,
            Color.white,
            DesignSystem.Colors.teal.opacity(0.7),
        ]
        particles = (0..<count).map { _ in
            let angle = Double.random(in: -Double.pi * 0.85 ... -Double.pi * 0.15)
            let speed = Double.random(in: 380...980)
            return Particle(
                start: CGPoint(x: CGFloat.random(in: 0.3...0.7), y: 0.62),
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                size: CGFloat.random(in: 5...11),
                spin: Double.random(in: -8...8),
                color: palette.randomElement() ?? .white
            )
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSince(startDate)
                guard t < 1.6 else { return }
                let gravity = 1350.0
                let fade = t < 1.0 ? 1.0 : max(0, 1.0 - (t - 1.0) / 0.6)

                for particle in particles {
                    let x = particle.start.x * size.width + particle.velocity.dx * t
                    let y = particle.start.y * size.height + particle.velocity.dy * t + 0.5 * gravity * t * t
                    guard y < size.height + 20 else { continue }

                    var rect = context
                    rect.translateBy(x: x, y: y)
                    rect.rotate(by: .radians(particle.spin * t))
                    rect.opacity = fade
                    rect.fill(
                        Path(CGRect(
                            x: -particle.size / 2, y: -particle.size / 4,
                            width: particle.size, height: particle.size / 2
                        )),
                        with: .color(particle.color)
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        ConfettiView()
    }
}
