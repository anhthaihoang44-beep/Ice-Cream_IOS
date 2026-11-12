import SwiftUI

enum GelatoFlavorType: String, CaseIterable, Identifiable {
    case chocolate = "Chocolate"
    case strawberry = "Strawberry"
    case vanilla = "Vanilla"
    case kiwi = "Mint Kiwi"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .chocolate: return "🍫"
        case .strawberry: return "🍓"
        case .vanilla: return "🍦"
        case .kiwi: return "🥝"
        }
    }

    var color: Color {
        switch self {
        case .chocolate: return Color(hex: 0xFF5D4037)
        case .strawberry: return Color(hex: 0xFFFF4081)
        case .vanilla: return Color(hex: 0xFFFFF59D)
        case .kiwi: return Color(hex: 0xFF80CBC4)
        }
    }
}

struct GelatoView: View {
    @ObservedObject var appState: AppState

    @State private var scoops: [GelatoFlavorType] = []
    @State private var bitesTaken: Int = 0
    @State private var showCelebration: Bool = false
    @State private var animalMood: AnimalMood = .waiting

    var isFull: Bool { scoops.count >= 3 }

    var stepTitle: String {
        if isFull {
            return "😋 STEP 2: FEED 3-SCOOP CONE TO PET! 🐶"
        } else {
            return "🍨 TAP ICE CREAM TUB TO SCOOP CONE (\(scoops.count)/3)! 🍨"
        }
    }

    var body: some View {
        ZStack {
            // Kitchen Background
            GameImage(name: "bg_kitchen", contentMode: .fill)
                .ignoresSafeArea()

            // Counter table
            VStack {
                Spacer()
                GameImage(name: "table_counter", contentMode: .fill)
                    .frame(height: 120)
            }
            .ignoresSafeArea()

            VStack(spacing: 6) {
                // Header Bar
                GameTopBar(
                    title: stepTitle,
                    onBack: { appState.navigate(to: .menu) },
                    onRestart: { resetState() }
                )

                // Main Stage Row
                HStack(spacing: 24) {
                    // Left: 4 Tubs in 2x2 Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🍧 Tap ice cream tub to scoop cone:")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.pinkStrawberry)
                            .padding(.horizontal, 6)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(GelatoFlavorType.allCases) { flavor in
                                Button(action: {
                                    addScoop(flavor)
                                }) {
                                    VStack(spacing: 3) {
                                        Text(flavor.emoji).font(.system(size: 28))
                                        Text(flavor.rawValue)
                                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                                            .foregroundColor(.textDark)
                                        Text("+ Scoop")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.pinkStrawberry)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.pinkSoft)
                                            .clipShape(Capsule())
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 85)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(flavor.color, lineWidth: 2))
                                    .shadow(color: Color.black.opacity(0.06), radius: 3)
                                }
                            }
                        }
                    }
                    .frame(width: 250)

                    // Right: Serving Stage with Customer and Stacking Cone
                    HStack(spacing: 20) {
                        // Customer Animal
                        VStack {
                            AnimalCustomerView(animalType: appState.selectedAnimal, mood: animalMood, size: 130)
                            Text(appState.selectedAnimal.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.textDark)
                        }

                        // Stacking Waffle Cone matching Android
                        ZStack {
                            VStack(spacing: -18) {
                                // Stacked Scoops
                                ForEach(Array(scoops.enumerated().reversed()), id: \.offset) { index, flavor in
                                    if index >= bitesTaken {
                                        Circle()
                                            .fill(flavor.color)
                                            .frame(width: 80 - CGFloat(index) * 4, height: 70)
                                            .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2.5))
                                            .shadow(color: Color.black.opacity(0.1), radius: 3)
                                            .transition(.scale)
                                    }
                                }

                                // Waffle Cone
                                GameImage(name: "ss_cone")
                                    .frame(width: 85, height: 100)
                            }
                        }
                        .frame(width: 140)
                        .onTapGesture {
                            if isFull && bitesTaken < 3 {
                                feedBite()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.white.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.pinkStrawberry.opacity(0.4), lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }

            ConfettiView(isActive: showCelebration)
        }
    }

    private func addScoop(_ flavor: GelatoFlavorType) {
        guard scoops.count < 3 else { return }
        AudioManager.shared.playSFX("sfx_scoop")
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            scoops.append(flavor)
        }
    }

    private func feedBite() {
        AudioManager.shared.playSFX("sfx_yummy")
        animalMood = .eating
        withAnimation {
            bitesTaken += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if bitesTaken >= 3 {
                animalMood = .happy
                AudioManager.shared.playSFX("sfx_celebrate")
                appState.addCoins(25)
                showCelebration = true
            } else {
                animalMood = .waiting
            }
        }
    }

    private func resetState() {
        scoops = []
        bitesTaken = 0
        showCelebration = false
        animalMood = .waiting
    }
}
