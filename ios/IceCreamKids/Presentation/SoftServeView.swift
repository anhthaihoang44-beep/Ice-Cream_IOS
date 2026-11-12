import SwiftUI

enum SoftServeFlavor: String, CaseIterable, Identifiable {
    case strawberry = "Strawberry"
    case chocolate = "Chocolate"
    case vanilla = "Vanilla"
    case kiwi = "Mint Kiwi"
    case blueberry = "Blueberry"

    var id: String { rawValue }

    var bottomAsset: String {
        switch self {
        case .strawberry: return "swirl_strawberry_bottom"
        case .chocolate: return "swirl_choco_bottom"
        case .vanilla: return "swirl_vanilla_bottom"
        case .kiwi: return "swirl_kiwi_bottom"
        case .blueberry: return "swirl_blueberry_bottom"
        }
    }

    var topAsset: String {
        switch self {
        case .strawberry: return "swirl_strawberry_top"
        case .chocolate: return "swirl_choco_top"
        case .vanilla: return "swirl_vanilla_top"
        case .kiwi: return "swirl_kiwi_top"
        case .blueberry: return "swirl_blueberry_top"
        }
    }

    var color: Color {
        switch self {
        case .strawberry: return Color(hex: 0xFFFF6492)
        case .chocolate: return Color(hex: 0xFF6D4C41)
        case .vanilla: return Color(hex: 0xFFFFF9C4)
        case .kiwi: return Color(hex: 0xFF81C784)
        case .blueberry: return Color(hex: 0xFF7E57C2)
        }
    }
}

struct SoftServeView: View {
    @ObservedObject var appState: AppState

    @State private var step: Int = 1 // 1: Choose Cone, 2: Pull Lever & Dispense, 3: Decorate Toppings, 4: Feed Pet
    @State private var bottomFlavor: SoftServeFlavor = .strawberry
    @State private var topFlavor: SoftServeFlavor = .vanilla
    @State private var isDispensing: Bool = false
    @State private var dispensedAmount: CGFloat = 0 // 0 to 1
    @State private var selectedToppings: Set<String> = []
    @State private var bitesTaken: Int = 0
    @State private var showCelebration: Bool = false
    @State private var animalMood: AnimalMood = .waiting

    var stepTitle: String {
        switch step {
        case 1: return "🍦 STEP 1: CHOOSE CONE & FLAVORS! 🍦"
        case 2: return "🍦 STEP 2: HOLD LEVER TO DISPENSE SWIRL! 🍦"
        case 3: return "✨ STEP 3: DECORATE DELICIOUS TOPPINGS! ✨"
        default: return "😋 STEP 4: FEED YOUR PET! 🐶"
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
                // Top Header Bar
                GameTopBar(
                    title: stepTitle,
                    onBack: { appState.navigate(to: .menu) },
                    onRestart: { resetState() }
                )

                // Main Stage Row
                HStack(spacing: 20) {
                    // Left: Soft Serve Machine Stage
                    ZStack {
                        if step <= 2 {
                            machineStageView
                        } else {
                            coneServingStageView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Control Panels
                    VStack {
                        switch step {
                        case 1:
                            flavorControlsView
                        case 2:
                            dispenseControlsView
                        case 3:
                            toppingControlsView
                        default:
                            feedPetControlsView
                        }
                    }
                    .frame(width: 310)
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

    // MARK: - Machine Stage
    private var machineStageView: some View {
        ZStack {
            // Soft Serve Machine Base
            GameImage(name: "select_machine_ss")
                .frame(width: 210, height: 250)

            // Lever
            GameImage(name: "ss_lever")
                .frame(width: 50, height: 75)
                .rotationEffect(.degrees(isDispensing ? 25 : 0))
                .offset(x: 55, y: -25)
                .onTapGesture {
                    pullLeverAction()
                }

            // Dispensing Swirl Cone below nozzle
            if step == 2 {
                VStack(spacing: -18) {
                    if dispensedAmount > 0.6 {
                        GameImage(name: topFlavor.topAsset)
                            .frame(width: 85, height: 75)
                            .transition(.scale)
                    }
                    if dispensedAmount > 0.2 {
                        GameImage(name: bottomFlavor.bottomAsset)
                            .frame(width: 100, height: 75)
                            .transition(.scale)
                    }
                    GameImage(name: "ss_cone")
                        .frame(width: 75, height: 90)
                }
                .offset(y: 75)
            }
        }
    }

    // MARK: - Serving Stage
    private var coneServingStageView: some View {
        HStack(spacing: 20) {
            // Customer Animal
            VStack {
                AnimalCustomerView(animalType: appState.selectedAnimal, mood: animalMood, size: 130)
                Text(appState.selectedAnimal.rawValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.textDark)
            }

            // Finished Ice Cream Cone
            ZStack {
                VStack(spacing: -18) {
                    if bitesTaken < 3 {
                        ZStack {
                            GameImage(name: topFlavor.topAsset)
                                .frame(width: 95, height: 85)

                            // Toppings on top
                            if selectedToppings.contains("ss_bit_sprinkles") {
                                GameImage(name: "ss_bit_sprinkles")
                                    .frame(width: 75, height: 45)
                                    .offset(y: -5)
                            }
                            if selectedToppings.contains("ss_bit_cherry") {
                                GameImage(name: "ss_bit_cherry")
                                    .frame(width: 32, height: 32)
                                    .offset(y: -30)
                            }
                            if selectedToppings.contains("ss_bit_strawberry") {
                                GameImage(name: "ss_bit_strawberry")
                                    .frame(width: 30, height: 30)
                                    .offset(x: 15, y: -20)
                            }
                            if selectedToppings.contains("ss_bit_blueberry") {
                                GameImage(name: "ss_bit_blueberry")
                                    .frame(width: 28, height: 28)
                                    .offset(x: -15, y: -18)
                            }
                        }
                    }

                    if bitesTaken < 2 {
                        GameImage(name: bottomFlavor.bottomAsset)
                            .frame(width: 110, height: 85)
                    }

                    GameImage(name: "ss_cone")
                        .frame(width: 80, height: 95)
                }
            }
            .onTapGesture {
                if step == 4 && bitesTaken < 3 {
                    feedBite()
                }
            }
        }
    }

    // MARK: - Controls
    private var flavorControlsView: some View {
        VStack(spacing: 8) {
            Text("🍓 Bottom Swirl Flavor:")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            HStack(spacing: 6) {
                ForEach(SoftServeFlavor.allCases) { f in
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        bottomFlavor = f
                    }) {
                        Text(f.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(bottomFlavor == f ? .white : .textDark)
                            .frame(width: 54, height: 32)
                            .background(bottomFlavor == f ? f.color : Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(f.color, lineWidth: 1.5))
                    }
                }
            }

            Spacer().frame(height: 4)

            Text("🍦 Top Swirl Flavor:")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            HStack(spacing: 6) {
                ForEach(SoftServeFlavor.allCases) { f in
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        topFlavor = f
                    }) {
                        Text(f.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(topFlavor == f ? .white : .textDark)
                            .frame(width: 54, height: 32)
                            .background(topFlavor == f ? f.color : Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(f.color, lineWidth: 1.5))
                    }
                }
            }

            Spacer().frame(height: 8)

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation { step = 2 }
            }) {
                Text("NEXT: DISPENSE ▶")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var dispenseControlsView: some View {
        VStack(spacing: 12) {
            Text("🍦 Pull Lever To Dispense")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            Text("Tap the button or lever to pour delicious swirls into cone!")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)

            Button(action: {
                pullLeverAction()
            }) {
                Text(isDispensing ? "🌪️ SWIRLING..." : "PULL LEVER 🔽")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            if dispensedAmount >= 1.0 {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_pop")
                    withAnimation { step = 3 }
                }) {
                    Text("DECORATE CONE 👉")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.mintGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var toppingControlsView: some View {
        VStack(spacing: 8) {
            Text("🍒 Choose Toppings:")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            let toppings = [
                ("ss_bit_sprinkles", "🌈 Sprinkles"),
                ("ss_bit_cherry", "🍒 Cherry"),
                ("ss_bit_strawberry", "🍓 Strawberry"),
                ("ss_bit_blueberry", "🫐 Blueberry")
            ]

            ForEach(toppings, id: \.0) { asset, label in
                Button(action: {
                    AudioManager.shared.playSFX("sfx_sprinkle")
                    if selectedToppings.contains(asset) {
                        selectedToppings.remove(asset)
                    } else {
                        selectedToppings.insert(asset)
                    }
                }) {
                    HStack {
                        GameImage(name: asset)
                            .frame(width: 24, height: 24)
                        Text(label)
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        if selectedToppings.contains(asset) {
                            Text("✓").bold().foregroundColor(.mintDark)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(selectedToppings.contains(asset) ? Color.mintGreen.opacity(0.3) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pinkLight.opacity(0.5), lineWidth: 1.5))
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation {
                    step = 4
                    animalMood = .waiting
                }
            }) {
                Text("SERVE TO PET! 😋")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var feedPetControlsView: some View {
        VStack(spacing: 8) {
            Text(bitesTaken < 3 ? "👉 Tap the cone to feed your pet!" : "🎉 Yummy! Your pet loved it! (+25 Coins)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            if bitesTaken >= 3 {
                Button(action: {
                    resetState()
                }) {
                    Text("Make Another Cone 🔄")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.mintGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func pullLeverAction() {
        guard dispensedAmount < 1.0 else { return }
        AudioManager.shared.playSFX("sfx_pour")
        isDispensing = true

        withAnimation(.easeInOut(duration: 0.8)) {
            dispensedAmount = min(1.0, dispensedAmount + 0.5)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isDispensing = false
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
        step = 1
        dispensedAmount = 0
        selectedToppings = []
        bitesTaken = 0
        showCelebration = false
        animalMood = .waiting
    }
}
