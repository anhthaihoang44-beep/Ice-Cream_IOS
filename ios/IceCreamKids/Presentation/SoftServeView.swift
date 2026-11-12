import SwiftUI

enum SoftServeFlavor: String, CaseIterable, Identifiable {
    case vanilla = "Vanilla"
    case strawberry = "Strawberry"
    case chocolate = "Chocolate"
    case mintKiwi = "Mint Kiwi"
    case blueberry = "Blueberry"

    var id: String { rawValue }

    var bottomAsset: String {
        switch self {
        case .vanilla: return "swirl_vanilla_bottom"
        case .strawberry: return "swirl_strawberry_bottom"
        case .chocolate: return "swirl_chocolate_bottom"
        case .mintKiwi: return "swirl_kiwi_bottom"
        case .blueberry: return "swirl_blueberry_bottom"
        }
    }

    var topAsset: String {
        switch self {
        case .vanilla: return "swirl_vanilla_top"
        case .strawberry: return "swirl_strawberry_top"
        case .chocolate: return "swirl_chocolate_top"
        case .mintKiwi: return "swirl_kiwi_top"
        case .blueberry: return "swirl_blueberry_top"
        }
    }
}

struct SoftServeView: View {
    @ObservedObject var appState: AppState

    @State private var currentStep: Int = 1 // 1: Cone, 2: Swirl, 3: Topping, 4: Eat
    @State private var selectedCone: String = "cone_waffle"
    @State private var bottomFlavor: SoftServeFlavor = .strawberry
    @State private var topFlavor: SoftServeFlavor = .vanilla
    @State private var isDispensing: Bool = false
    @State private var dispensedAmount: CGFloat = 0 // 0 to 1
    @State private var hasSprinkles: Bool = false
    @State private var hasCherry: Bool = false
    @State private var bitesTaken: Int = 0
    @State private var showCelebration: Bool = false

    var stepTitle: String {
        switch currentStep {
        case 1: return "🍦 1. CHOOSE YOUR CONE OR CUP! 🍦"
        case 2: return "🍦 2. HOLD LEVER TO DISPENSE SWIRL ICE CREAM! 🍦"
        case 3: return "✨ 3. CHOOSE DELICIOUS TOPPINGS TO DECORATE! ✨"
        default: return "🎉 DELICIOUS SOFT SERVE IS READY! 🎉"
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
                HStack(spacing: 20) {
                    // Left: Soft Serve Machine or Assembled Cone
                    ZStack {
                        if currentStep == 2 {
                            machineStageView
                        } else {
                            coneStageView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Control Panels
                    VStack {
                        switch currentStep {
                        case 1:
                            coneControls
                        case 2:
                            dispenseControls
                        case 3:
                            toppingControls
                        default:
                            eatControls
                        }
                    }
                    .frame(width: 320)
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

    // MARK: - Stages
    private var machineStageView: some View {
        ZStack {
            // Soft Serve Machine
            GameImage(name: "select_machine_ss")
                .frame(width: 220, height: 260)

            // Lever
            GameImage(name: isDispensing ? "ss_handle_pull" : "ss_handle_idle")
                .frame(width: 70, height: 70)
                .offset(x: 55, y: -20)
                .onTapGesture {
                    pullLeverOnce()
                }

            // Swirl building up below nozzle
            if dispensedAmount > 0.1 {
                VStack(spacing: -15) {
                    if dispensedAmount > 0.6 {
                        GameImage(name: topFlavor.topAsset)
                            .frame(width: 90, height: 80)
                    }
                    GameImage(name: bottomFlavor.bottomAsset)
                        .frame(width: 105, height: 80)
                    GameImage(name: selectedCone)
                        .frame(width: 80, height: 95)
                }
                .offset(y: 70)
            }
        }
    }

    private var coneStageView: some View {
        ZStack {
            if bitesTaken < 3 {
                VStack(spacing: -24) {
                    // Top Swirl
                    if currentStep >= 3 {
                        ZStack {
                            GameImage(name: topFlavor.topAsset)
                                .frame(width: 120, height: 110)

                            if hasSprinkles {
                                GameImage(name: "ss_bit_sprinkles")
                                    .frame(width: 90, height: 50)
                                    .offset(y: -10)
                            }
                        }
                    }

                    // Bottom Swirl
                    if currentStep >= 3 {
                        GameImage(name: bottomFlavor.bottomAsset)
                            .frame(width: 140, height: 105)
                    }

                    // Cone Base
                    GameImage(name: selectedCone)
                        .frame(width: 100, height: 120)
                }
                .offset(y: 20)
            }
        }
        .onTapGesture {
            if currentStep == 4 && bitesTaken < 3 {
                takeBite()
            }
        }
    }

    // MARK: - Controls
    private var coneControls: some View {
        VStack(spacing: 12) {
            Text("✨ 1. Choose Cone or Cup:")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            HStack(spacing: 8) {
                ConeButton(name: "Waffle", asset: "cone_waffle", isSelected: selectedCone == "cone_waffle") {
                    selectedCone = "cone_waffle"
                }
                ConeButton(name: "Rainbow", asset: "cone_cup", isSelected: selectedCone == "cone_cup") {
                    selectedCone = "cone_cup"
                }
                ConeButton(name: "Bear Bowl", asset: "cone_bear", isSelected: selectedCone == "cone_bear") {
                    selectedCone = "cone_bear"
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation { currentStep = 2 }
            }) {
                Text("NEXT: DISPENSE SWIRL 👉")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var dispenseControls: some View {
        VStack(spacing: 8) {
            Text("🍦 Choose Flavors & Dispense:")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            // Bottom flavor selector
            Text("Layer 1 (Bottom):")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.textMuted)

            HStack(spacing: 4) {
                ForEach(SoftServeFlavor.allCases) { f in
                    Button(action: { bottomFlavor = f }) {
                        Text(f.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(bottomFlavor == f ? .white : .textDark)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(bottomFlavor == f ? Color.pinkStrawberry : Color.white)
                            .clipShape(Capsule())
                    }
                }
            }

            Text("Layer 2 (Top):")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.textMuted)

            HStack(spacing: 4) {
                ForEach(SoftServeFlavor.allCases) { f in
                    Button(action: { topFlavor = f }) {
                        Text(f.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(topFlavor == f ? .white : .textDark)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(topFlavor == f ? Color.pinkStrawberry : Color.white)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer().frame(height: 4)

            // Hold lever button
            Button(action: {
                pullLeverOnce()
            }) {
                Text(dispensedAmount < 1.0 ? "👇 TAP LEVER TO DISPENSE (\(Int(dispensedAmount * 100))%)" : "✓ FULL! NEXT TO DECORATE")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(dispensedAmount >= 1.0 ? Color.mintGreen : Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var toppingControls: some View {
        VStack(spacing: 10) {
            Text("🍒 Sweet Toppings:")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            HStack(spacing: 12) {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_sprinkle")
                    hasSprinkles.toggle()
                }) {
                    VStack(spacing: 4) {
                        Text("🌈")
                            .font(.system(size: 26))
                        Text("Sprinkles")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.textDark)
                    }
                    .frame(width: 80, height: 60)
                    .background(hasSprinkles ? Color.pinkLight.opacity(0.3) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pinkStrawberry, lineWidth: 1.5))
                }

                Button(action: {
                    AudioManager.shared.playSFX("sfx_pop")
                    hasCherry.toggle()
                }) {
                    VStack(spacing: 4) {
                        Text("🍒")
                            .font(.system(size: 26))
                        Text("Cherry")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.textDark)
                    }
                    .frame(width: 80, height: 60)
                    .background(hasCherry ? Color.pinkLight.opacity(0.3) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pinkStrawberry, lineWidth: 1.5))
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation { currentStep = 4 }
            }) {
                Text("DONE & EAT ICE CREAM! 😋")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.mintGreen)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var eatControls: some View {
        VStack(spacing: 8) {
            Text(bitesTaken < 3 ? "😋 Tap the ice cream to take yummy bites!" : "🎉 You finished the soft serve! (+20 Coins)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            if bitesTaken >= 3 {
                Button(action: {
                    resetState()
                }) {
                    Text("Make Another Soft Serve 🍦")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.pinkStrawberry)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func pullLeverOnce() {
        AudioManager.shared.playSFX("sfx_pour")
        isDispensing = true
        withAnimation {
            dispensedAmount = min(1.0, dispensedAmount + 0.35)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isDispensing = false
            if dispensedAmount >= 1.0 {
                withAnimation { currentStep = 3 }
            }
        }
    }

    private func takeBite() {
        AudioManager.shared.playSFX("sfx_yummy")
        withAnimation {
            bitesTaken += 1
        }
        if bitesTaken >= 3 {
            AudioManager.shared.playSFX("sfx_celebrate")
            appState.addCoins(20)
            showCelebration = true
        }
    }

    private func resetState() {
        currentStep = 1
        dispensedAmount = 0
        hasSprinkles = false
        hasCherry = false
        bitesTaken = 0
        showCelebration = false
    }
}

struct ConeButton: View {
    let name: String
    let asset: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                GameImage(name: asset)
                    .frame(width: 48, height: 50)
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textDark)
            }
            .frame(width: 85, height: 80)
            .background(isSelected ? Color.pinkLight.opacity(0.3) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.pinkStrawberry : Color.gray.opacity(0.3), lineWidth: 2))
        }
    }
}
