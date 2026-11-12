import SwiftUI

// MARK: - Game Top Bar
struct GameTopBar: View {
    let title: String
    var onBack: () -> Void
    var onRestart: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                GameImage(name: "btn_back")
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Header Banner
            Text(title)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.95))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.pinkStrawberry.opacity(0.4), lineWidth: 2))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

            Spacer()

            if let onRestart = onRestart {
                Button(action: onRestart) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.pinkStrawberry)
                        .frame(width: 42, height: 42)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pinkStrawberry.opacity(0.3), lineWidth: 2))
                }
            } else {
                Spacer().frame(width: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Header Badges
struct CoinBadge: View {
    let coins: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("🪙")
                .font(.system(size: 18))
            Text("\(coins) Coins")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(.textDark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hex: 0xFFFFF59D))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.yellowMango, lineWidth: 2))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct FreeEditionBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("🎉")
                .font(.system(size: 15))
            Text("100% Free Edition")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: 0xFF00796B))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.mintGreen)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Confetti Particle Effect
struct ConfettiView: View {
    let isActive: Bool

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isActive {
                    ForEach(particles) { p in
                        Circle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size)
                            .position(x: p.x, y: p.y)
                            .opacity(p.opacity)
                    }
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
            }
            .onChange(of: isActive) { active in
                if active {
                    generateParticles(in: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func generateParticles(in size: CGSize) {
        let colors: [Color] = [.pinkStrawberry, .mintGreen, .yellowMango, .blueSky, .orangePeach, .purple]
        particles = (0..<40).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 40...(size.width - 40)),
                y: CGFloat.random(in: 30...(size.height * 0.7)),
                size: CGFloat.random(in: 8...16),
                color: colors.randomElement() ?? .pinkStrawberry,
                opacity: Double.random(in: 0.7...1.0)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

