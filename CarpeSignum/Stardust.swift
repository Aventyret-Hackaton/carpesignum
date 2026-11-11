import SwiftUI

/// Bonusteknik: konfetti. Här i form av kosmiskt stjärnstoft i guld,
/// så att tonen förblir allvarlig. Öka `trigger` för att släppa en skur.
struct Stardust: View {
    let trigger: Int

    private struct Burst: Identifiable {
        let id = UUID()
        let start: Date
        let particles: [Particle]
    }

    private struct Particle {
        let x: CGFloat        // 0–1 över skärmens bredd
        let vx: CGFloat
        let vy: CGFloat
        let size: CGFloat
        let spin: Double
        let star: Bool
        let color: Color
    }

    static let lifetime: TimeInterval = 3.5
    @State private var bursts: [Burst] = []

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { gc, size in
                let now = context.date
                for burst in bursts {
                    let t = now.timeIntervalSince(burst.start)
                    guard t < Self.lifetime else { continue }
                    let fade = 1 - max(0, (t - Self.lifetime * 0.6) / (Self.lifetime * 0.4))
                    for p in burst.particles {
                        let x = p.x * size.width + p.vx * t
                        let y = -20 + p.vy * t + 0.5 * 160 * t * t
                        var g = gc
                        g.opacity = fade
                        g.translateBy(x: x, y: y)
                        g.rotate(by: .radians(p.spin * t))
                        if p.star {
                            g.draw(Text("✶").font(.system(size: p.size * 2.2)).foregroundStyle(p.color), at: .zero)
                        } else {
                            g.fill(Path(ellipseIn: CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size)),
                                   with: .color(p.color))
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onChange(of: trigger) { _, _ in burst() }
    }

    private func burst() {
        let colors = [Theme.accent, Theme.accent, Theme.accent.opacity(0.6), Theme.text.opacity(0.7), Theme.muted]
        let particles = (0..<70).map { _ in
            Particle(x: .random(in: 0...1),
                     vx: .random(in: -40...40),
                     vy: .random(in: 30...180),
                     size: .random(in: 2...5),
                     spin: .random(in: -4...4),
                     star: Double.random(in: 0...1) < 0.3,
                     color: colors.randomElement()!)
        }
        let now = Date()
        bursts.removeAll { now.timeIntervalSince($0.start) > Self.lifetime }
        bursts.append(Burst(start: now, particles: particles))
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.lifetime + 0.1) {
            bursts.removeAll { Date().timeIntervalSince($0.start) > Self.lifetime }
        }
    }
}
