import SwiftUI

enum SweetIceFlavorType: String, CaseIterable, Identifiable {
    case banana = "Banana Milk"
    case peach = "Peach Milk"
    case watermelon = "Watermelon"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .banana: return "🍌"
        case .peach: return "🍑"
        case .watermelon: return "🍉"
        }
    }

    var iceAsset: String {
        switch self {
        case .banana: return "si_ice_banana"
        case .peach: return "si_ice_peach"
        case .watermelon: return "si_ice_watermelon"
        }
    }

    var color: Color {
        switch self {
        case .banana: return Color(hex: 0xFFFFF176)
        case .peach: return Color(hex: 0xFFFFCC80)
        case .watermelon: return Color(hex: 0xFFFF8A80)
        }
    }
}

struct SweetIceView: View {
    @ObservedObject var appState: AppState

    @State private var phase: Int = 1 // 1: Pour juice to tray, 2: Freeze, 3: Hammer bonk, 4: Feed Pet
    @State private var selectedFlavor: SweetIceFlavorType = .banana
    @State private var trayCells: [SweetIceFlavorType?] = Array(repeating: nil, count: 6)
    @State private var poppedCount: Int = 0
    @State private var isFreezing: Bool = false
    @State private var hammerAngle: Double = 0
    @State private var bitesTaken: Int = 0
    @State private var showCelebration: Bool = false
    @State private var animalMood: AnimalMood = .waiting

    var stepTitle: String {
        switch phase {
        case 1: return "🧃 STEP 1: TAP ICE TRAY TO POUR FRUIT MILK! 🧃"
        case 2: return "❄️ STEP 2: FREEZING ICE CUBES SOLID... ❄️"
        case 3: return "🔨 STEP 3: TAP HAMMER TO POP CUBES INTO BOWL (\(poppedCount)/6)! 🍨"
        default: return "😋 STEP 4: FEED SWEET ICE DISH TO PET! 🐶"
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
                HStack(spacing: 20) {
                    // Left: Tray / Dish Mound Stage
                    ZStack {
                        if phase <= 3 && poppedCount < 6 {
                            trayStageView
                        } else {
                            dishMoundServingStageView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Control Panels
                    VStack {
                        switch phase {
                        case 1:
                            pourControlsView
                        case 2:
                            freezeControlsView
                        case 3:
                            hammerControlsView
                        default:
                            feedPetControlsView
                        }
                    }
                    .frame(width: 310)
                    .padding(14)
                    .background(Color.white.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.blueSky.opacity(0.4), lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }

            ConfettiView(isActive: showCelebration)
        }
    }

    // MARK: - Stages
    private var trayStageView: some View {
        ZStack {
            // Ice Tray Container
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: 0xFFE1F5FE))
                .frame(width: 250, height: 180)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.blueSky, lineWidth: 3.5))
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)

            // 6 Ice Slots (2 rows x 3 columns)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(64), spacing: 14), count: 3), spacing: 14) {
                ForEach(0..<6, id: \.self) { idx in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(trayCells[idx]?.color ?? Color.white.opacity(0.7))
                            .frame(width: 62, height: 62)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.25), lineWidth: 1.5))

                        if let flavor = trayCells[idx] {
                            if phase >= 2 {
                                GameImage(name: flavor.iceAsset)
                                    .frame(width: 46, height: 46)
                            } else {
                                Text(flavor.emoji)
                                    .font(.system(size: 26))
                            }
                        }
                    }
                    .onTapGesture {
                        if phase == 1 {
                            fillSlot(at: idx)
                        } else if phase == 3 && poppedCount < 6 {
                            popSlot(at: idx)
                        }
                    }
                }
            }

            // Animated Wooden Mallet
            if phase == 3 {
                GameImage(name: "si_hammer")
                    .frame(width: 75, height: 75)
                    .rotationEffect(.degrees(hammerAngle))
                    .offset(x: 110, y: -80)
                    .onTapGesture {
                        bonkHammer()
                    }
            }
        }
    }

    private var dishMoundServingStageView: some View {
        HStack(spacing: 20) {
            // Customer Animal
            VStack {
                AnimalCustomerView(animalType: appState.selectedAnimal, mood: animalMood, size: 130)
                Text(appState.selectedAnimal.rawValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.textDark)
            }

            // Glass Bowl Dish with Mound of Sweet Ice Cubes
            ZStack {
                // Glass Bowl Dish
                GameImage(name: "si_cup_dish")
                    .frame(width: 200, height: 180)
                    .offset(y: 35)

                if bitesTaken < 3 {
                    // Tumbling 3D Sweet Ice Mound matching Android
                    ZStack {
                        ForEach(0..<min(6, 6 - bitesTaken * 2), id: \.self) { i in
                            let angle = [-14.0, 16.0, 4.0, -18.0, 15.0, -6.0][i % 6]
                            let offsetX = [-35.0, 32.0, -12.0, 24.0, -20.0, 6.0][i % 6]
                            let offsetY = [-10.0, -15.0, -42.0, -56.0, -78.0, -92.0][i % 6]

                            GameImage(name: selectedFlavor.iceAsset)
                                .frame(width: 48, height: 48)
                                .rotationEffect(.degrees(angle))
                                .offset(x: offsetX, y: offsetY)
                        }
                    }
                }
            }
            .onTapGesture {
                if bitesTaken < 3 {
                    feedBite()
                }
            }
        }
    }

    // MARK: - Controls
    private var pourControlsView: some View {
        VStack(spacing: 8) {
            Text("🧃 Fruit Milk Flavors:")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)

            HStack(spacing: 6) {
                ForEach(SweetIceFlavorType.allCases) { flavor in
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        selectedFlavor = flavor
                    }) {
                        VStack(spacing: 2) {
                            Text(flavor.emoji).font(.system(size: 20))
                            Text(flavor.rawValue).font(.system(size: 9, weight: .bold)).foregroundColor(.textDark)
                        }
                        .frame(width: 86, height: 50)
                        .background(selectedFlavor == flavor ? flavor.color.opacity(0.4) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(flavor.color, lineWidth: 2))
                    }
                }
            }

            Spacer().frame(height: 6)

            Button(action: {
                fillAllSlots()
            }) {
                Text("FILL ALL SLOTS 🧃")
                    .font(.system(size: 12, weight: .bold))
                    .frame(maxWidth: .infinity).frame(height: 36)
                    .background(Color.blueSky)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            if trayCells.allSatisfy({ $0 != nil }) {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_click")
                    startFreezingAction()
                }) {
                    Text("FREEZE IN FREEZER ❄️")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Color.mintGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var freezeControlsView: some View {
        VStack(spacing: 12) {
            Text("❄️ Freezing Solid... ❄️")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blueSky))
                .scaleEffect(1.3)
        }
    }

    private var hammerControlsView: some View {
        VStack(spacing: 10) {
            Text("🔨 Tap Hammer To Pop!")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)

            Text("Tap the mallet to pop the frozen cubes into the dessert bowl!")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)

            Button(action: {
                bonkHammer()
            }) {
                Text("TAP MALLET 🔨 (\(poppedCount)/6)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity).frame(height: 42)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var feedPetControlsView: some View {
        VStack(spacing: 8) {
            Text(bitesTaken < 3 ? "👉 Tap the bowl to feed your pet!" : "🎉 Awesome! Sweet Ice dish finished! (+25 Coins)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            if bitesTaken >= 3 {
                Button(action: {
                    resetState()
                }) {
                    Text("Make Another Dish 🍧")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Color.mintGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func fillSlot(at idx: Int) {
        AudioManager.shared.playSFX("sfx_pour")
        trayCells[idx] = selectedFlavor
    }

    private func fillAllSlots() {
        AudioManager.shared.playSFX("sfx_pour")
        for i in 0..<6 {
            trayCells[i] = selectedFlavor
        }
    }

    private func startFreezingAction() {
        AudioManager.shared.playSFX("sfx_freeze")
        phase = 2
        isFreezing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isFreezing = false
            withAnimation {
                phase = 3
            }
        }
    }

    private func bonkHammer() {
        guard poppedCount < 6 else { return }
        AudioManager.shared.playSFX("sfx_pop")

        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            hammerAngle = 25
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            hammerAngle = 0
            poppedCount += 1
            if poppedCount >= 6 {
                withAnimation {
                    phase = 4
                    animalMood = .waiting
                }
            }
        }
    }

    private func popSlot(at idx: Int) {
        bonkHammer()
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
        phase = 1
        trayCells = Array(repeating: nil, count: 6)
        poppedCount = 0
        bitesTaken = 0
        showCelebration = false
        animalMood = .waiting
    }
}
