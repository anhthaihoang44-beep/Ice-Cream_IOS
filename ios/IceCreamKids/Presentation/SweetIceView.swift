import SwiftUI

enum SweetIceStep {
    case pour
    case freeze
    case popHammer
    case enjoy
}

enum SweetIceFlavor: String, CaseIterable, Identifiable {
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

    var color: Color {
        switch self {
        case .banana: return Color(hex: 0xFFFFF59D)
        case .peach: return Color(hex: 0xFFFFCCBC)
        case .watermelon: return Color(hex: 0xFFFF8A80)
        }
    }
}

struct SweetIceView: View {
    @ObservedObject var appState: AppState

    @State private var step: SweetIceStep = .pour
    @State private var selectedFlavor: SweetIceFlavor = .watermelon
    @State private var filledCubesCount: Int = 0
    @State private var isFreezing: Bool = false
    @State private var poppedCubesCount: Int = 0
    @State private var showCelebration: Bool = false

    var stepTitle: String {
        switch step {
        case .pour: return "🧃 STEP 1: TAP TRAY TO POUR FRUIT MILK! 🧃"
        case .freeze: return "❄️ STEP 2: FREEZING ICE CUBES SOLID... ❄️"
        case .popHammer: return "🔨 STEP 3: TAP HAMMER TO POP CUBES INTO BOWL (\(poppedCubesCount)/6)! 🍨"
        case .enjoy: return "🎉 DELICIOUS SWEET ICE DESSERT IS READY! 🎉"
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
                    // Left: Ice Tray & Hammer / Glass Dish
                    ZStack {
                        if step == .pour || step == .freeze || (step == .popHammer && poppedCubesCount < 6) {
                            trayStageView
                        } else {
                            dishMoundStageView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Controls
                    VStack {
                        switch step {
                        case .pour:
                            pourControls
                        case .freeze:
                            freezeControls
                        case .popHammer:
                            hammerControls
                        case .enjoy:
                            enjoyControls
                        }
                    }
                    .frame(width: 320)
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
            // Ice Tray
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: 0xFFE1F5FE))
                .frame(width: 250, height: 180)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blueSky, lineWidth: 3))

            // 6 Ice Slots (2x3)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(60), spacing: 14), count: 3), spacing: 14) {
                ForEach(0..<6, id: \.self) { idx in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(idx < filledCubesCount ? selectedFlavor.color : Color.white.opacity(0.6))
                            .frame(width: 58, height: 58)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.3), lineWidth: 1.5))

                        if idx < filledCubesCount {
                            Text(selectedFlavor.emoji)
                                .font(.system(size: 24))
                        }
                    }
                    .onTapGesture {
                        if step == .pour {
                            fillSlot()
                        } else if step == .popHammer && poppedCubesCount < 6 {
                            popSlot()
                        }
                    }
                }
            }

            if step == .popHammer {
                // Wooden hammer
                GameImage(name: "si_tool_hammer")
                    .frame(width: 70, height: 70)
                    .offset(x: 110, y: -80)
            }
        }
    }

    private var dishMoundStageView: some View {
        ZStack {
            // Glass Dish
            GameImage(name: "si_cup_dish")
                .frame(width: 200, height: 180)
                .offset(y: 40)

            // Tumbling 3D Dessert Mound
            ZStack {
                ForEach(0..<poppedCubesCount, id: \.self) { i in
                    let angle = [-12.0, 14.0, 2.0, -16.0, 15.0, -5.0][i % 6]
                    let offsetX = [-35.0, 30.0, -10.0, 25.0, -20.0, 5.0][i % 6]
                    let offsetY = [-10.0, -15.0, -40.0, -55.0, -75.0, -90.0][i % 6]

                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedFlavor.color)
                        .frame(width: 50, height: 50)
                        .overlay(Text(selectedFlavor.emoji).font(.system(size: 22)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.8), lineWidth: 2))
                        .shadow(color: Color.black.opacity(0.12), radius: 3)
                        .rotationEffect(.degrees(angle))
                        .offset(x: offsetX, y: offsetY)
                }

                // Spoon resting on rim
                GameImage(name: "si_spoon_1")
                    .frame(width: 50, height: 100)
                    .rotationEffect(.degrees(35))
                    .offset(x: 75, y: -20)
            }
        }
    }

    // MARK: - Controls
    private var pourControls: some View {
        VStack(spacing: 10) {
            Text("🧃 Fruit Milk Flavors:")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)

            HStack(spacing: 6) {
                ForEach(SweetIceFlavor.allCases) { flavor in
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        selectedFlavor = flavor
                    }) {
                        VStack(spacing: 2) {
                            Text(flavor.emoji)
                                .font(.system(size: 24))
                            Text(flavor.rawValue)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.textDark)
                        }
                        .frame(width: 85, height: 62)
                        .background(selectedFlavor == flavor ? flavor.color : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blueSky, lineWidth: 1.5))
                    }
                }
            }

            // Fill button
            Button(action: {
                AudioManager.shared.playSFX("sfx_pour")
                filledCubesCount = 6
                withAnimation { step = .freeze }
            }) {
                Text("FILL TRAY & FREEZE 👉")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.blueSky)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var freezeControls: some View {
        VStack(spacing: 12) {
            Text("❄️ Freezing Solid...")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)

            Button(action: {
                startFreezing()
            }) {
                Text(isFreezing ? "❄️ FREEZING..." : "❄️ FREEZE NOW")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.blueSky)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .disabled(isFreezing)
        }
    }

    private var hammerControls: some View {
        VStack(spacing: 10) {
            Text("🔨 Tap ice cubes with hammer into dish!")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)
                .multilineTextAlignment(.center)

            Text("Popped \(poppedCubesCount)/6 fruit ice cubes!")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.textMuted)

            Button(action: {
                popSlot()
            }) {
                Text("POP CUBE WITH HAMMER 🔨")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.blueSky)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var enjoyControls: some View {
        VStack(spacing: 8) {
            Text("🎉 Beautiful fruit sweet ice dish is ready!")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            Button(action: {
                resetState()
            }) {
                Text("Make Another Sweet Ice 🍧")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.mintGreen)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private func fillSlot() {
        guard filledCubesCount < 6 else { return }
        AudioManager.shared.playSFX("sfx_pour")
        withAnimation {
            filledCubesCount += 1
        }
        if filledCubesCount >= 6 {
            withAnimation { step = .freeze }
        }
    }

    private func startFreezing() {
        AudioManager.shared.playSFX("sfx_freeze")
        isFreezing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isFreezing = false
            withAnimation {
                step = .popHammer
            }
        }
    }

    private func popSlot() {
        guard poppedCubesCount < 6 else { return }
        AudioManager.shared.playSFX("sfx_pop")
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            poppedCubesCount += 1
        }
        if poppedCubesCount >= 6 {
            AudioManager.shared.playSFX("sfx_celebrate")
            appState.addCoins(20)
            showCelebration = true
            withAnimation { step = .enjoy }
        }
    }

    private func resetState() {
        step = .pour
        filledCubesCount = 0
        isFreezing = false
        poppedCubesCount = 0
        showCelebration = false
    }
}

