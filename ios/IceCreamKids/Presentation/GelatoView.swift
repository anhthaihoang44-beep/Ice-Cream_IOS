import SwiftUI

enum GelatoFlavor: String, CaseIterable, Identifiable {
    case chocolate = "Chocolate"
    case strawberry = "Strawberry"
    case vanilla = "Vanilla"
    case mintKiwi = "Mint Kiwi"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .chocolate: return "🍫"
        case .strawberry: return "🍓"
        case .vanilla: return "🍦"
        case .mintKiwi: return "🥝"
        }
    }

    var color: Color {
        switch self {
        case .chocolate: return Color(hex: 0xFF5D4037)
        case .strawberry: return Color(hex: 0xFFFF4081)
        case .vanilla: return Color(hex: 0xFFFFF59D)
        case .mintKiwi: return Color(hex: 0xFF80CBC4)
        }
    }
}

struct GelatoView: View {
    @ObservedObject var appState: AppState

    @State private var scoops: [GelatoFlavor] = []
    @State private var bitesTaken: Int = 0
    @State private var showCelebration: Bool = false

    var isFull: Bool { scoops.count >= 3 }

    var stepTitle: String {
        if isFull {
            return "🎉 DELICIOUS 3-SCOOP CONE IS READY! 🎉"
        } else {
            return "🍨 TAP ICE CREAM TUB TO SCOOP ONTO CONE (\(scoops.count)/3)! 🍨"
        }
    }

    var body: some View {
        ZStack {
            // Background
            GameImage(name: "bg_kitchen", contentMode: .fill)
                .ignoresSafeArea()

            VStack {
                Spacer()
                GameImage(name: "table_counter", contentMode: .fill)
                    .frame(height: 120)
            }
            .ignoresSafeArea()

            VStack(spacing: 6) {
                // Top Header
                GameTopBar(
                    title: stepTitle,
                    onBack: { appState.navigate(to: .menu) },
                    onRestart: { resetState() }
                )

                // Main Stage
                HStack(spacing: 24) {
                    // Left: 4 Tubs in 2x2 Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🍧 Tap ice cream tub to scoop cone:")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.pinkStrawberry)
                            .padding(.horizontal, 8)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(GelatoFlavor.allCases) { flavor in
                                Button(action: {
                                    addScoop(flavor)
                                }) {
                                    VStack(spacing: 4) {
                                        Text(flavor.emoji)
                                            .font(.system(size: 32))
                                        Text(flavor.rawValue)
                                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                                            .foregroundColor(.textDark)
                                        Text("+ Scoop 1")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.pinkStrawberry)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.pinkSoft)
                                            .clipShape(Capsule())
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 95)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(flavor.color, lineWidth: 2.5)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                                }
                                .disabled(isFull)
                            }
                        }
                    }
                    .frame(width: 320)
                    .padding(.leading, 20)

                    // Right: Stacked Scoops onto Waffle Cone
                    ZStack {
                        VStack(spacing: -28) {
                            // 3rd scoop (top)
                            if scoops.count >= 3 {
                                Circle()
                                    .fill(scoops[2].color)
                                    .frame(width: 85, height: 85)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 3)
                            }

                            // 2nd scoop (middle)
                            if scoops.count >= 2 {
                                Circle()
                                    .fill(scoops[1].color)
                                    .frame(width: 100, height: 100)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 3)
                            }

                            // 1st scoop (bottom)
                            if scoops.count >= 1 {
                                Circle()
                                    .fill(scoops[0].color)
                                    .frame(width: 115, height: 115)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 3)
                            }

                            // Cone Base
                            GameImage(name: "cone_waffle")
                                .frame(width: 90, height: 115)
                        }
                        .offset(y: CGFloat(3 - scoops.count) * 15 + 20)
                        .onTapGesture {
                            if isFull && bitesTaken < 3 {
                                takeBite()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            ConfettiView(isActive: showCelebration)
        }
    }

    private func addScoop(_ flavor: GelatoFlavor) {
        guard scoops.count < 3 else { return }
        AudioManager.shared.playSFX("sfx_scoop")
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            scoops.append(flavor)
        }
        if scoops.count == 3 {
            AudioManager.shared.playSFX("sfx_celebrate")
            appState.addCoins(20)
            showCelebration = true
        }
    }

    private func takeBite() {
        AudioManager.shared.playSFX("sfx_yummy")
        withAnimation {
            bitesTaken += 1
        }
    }

    private func resetState() {
        scoops = []
        bitesTaken = 0
        showCelebration = false
    }
}

