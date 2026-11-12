import SwiftUI

enum PopsicleStep {
    case chooseMold
    case pourAndStick
    case freezeInFreezer
    case decorateAndFeed
}

enum PopsicleMold: String, CaseIterable, Identifiable {
    case strawberry = "Strawberry"
    case bunny = "Cute Bunny"
    case paw = "Kitty Paw"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .strawberry: return "🍓"
        case .bunny: return "🐰"
        case .paw: return "🐾"
        }
    }

    var moldAsset: String {
        switch self {
        case .strawberry: return "fjc_mold_strawberry"
        case .bunny: return "fjc_mold_bunny"
        case .paw: return "fjc_mold_paw"
        }
    }

    var popAsset: String {
        switch self {
        case .strawberry: return "fjc_pop_strawberry"
        case .bunny: return "fjc_pop_bunny"
        case .paw: return "fjc_pop_paw"
        }
    }
}

struct PopsicleView: View {
    @ObservedObject var appState: AppState

    @State private var step: PopsicleStep = .chooseMold
    @State private var selectedMold: PopsicleMold = .strawberry
    @State private var selectedJuice: String = "Red Strawberry"
    @State private var hasJuice: Bool = false
    @State private var hasStick: Bool = false
    @State private var isFreezing: Bool = false
    @State private var isFrozen: Bool = false
    @State private var hasChocolateDip: Bool = false
    @State private var hasSprinkles: Bool = false
    @State private var bitesTaken: Int = 0
    @State private var showCelebration: Bool = false

    var stepTitle: String {
        switch step {
        case .chooseMold: return "🍭 STEP 1: CHOOSE YOUR POPSICLE MOLD! 🍭"
        case .pourAndStick: return "🧃 STEP 2: POUR JUICE & INSERT WOODEN STICK! 🪵"
        case .freezeInFreezer: return "❄️ STEP 3: FREEZE SOLID IN THE FREEZER! ❄️"
        case .decorateAndFeed: return "🍫 STEP 4: DIP CHOCOLATE & FEED PET! 😋"
        }
    }

    var body: some View {
        ZStack {
            // Background
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
                // Top Header
                GameTopBar(
                    title: stepTitle,
                    onBack: { appState.navigate(to: .menu) },
                    onRestart: { resetState() }
                )

                // Main Stage
                HStack(spacing: 20) {
                    // Left: Popsicle Stage
                    ZStack {
                        if step == .chooseMold || step == .pourAndStick {
                            moldStageView
                        } else if step == .freezeInFreezer {
                            freezerStageView
                        } else {
                            finishedPopStageView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Controls
                    VStack {
                        switch step {
                        case .chooseMold:
                            step1Controls
                        case .pourAndStick:
                            step2Controls
                        case .freezeInFreezer:
                            step3Controls
                        case .decorateAndFeed:
                            step4Controls
                        }
                    }
                    .frame(width: 320)
                    .padding(14)
                    .background(Color.white.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.mintGreen.opacity(0.4), lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }

            ConfettiView(isActive: showCelebration)
        }
    }

    // MARK: - Stages
    private var moldStageView: some View {
        ZStack {
            // Wooden stick placed behind the mold so top is tucked inside!
            if hasStick {
                GameImage(name: "fjc_stick")
                    .frame(width: 34, height: 160)
                    .offset(y: 80)
            }

            // Mold Cavity
            GameImage(name: selectedMold.moldAsset)
                .frame(width: 170, height: 210)

            // Juice filling inside mold
            if hasJuice {
                GameImage(name: selectedMold.popAsset)
                    .frame(width: 140, height: 170)
                    .opacity(0.92)
            }
        }
    }

    private var freezerStageView: some View {
        ZStack {
            GameImage(name: "fjc_freezer_door")
                .frame(width: 220, height: 240)

            if isFreezing {
                Color.blue.opacity(0.2)
                    .frame(width: 200, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("❄️ -18°C ❄️")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 8)
            }
        }
    }

    private var finishedPopStageView: some View {
        ZStack {
            // Wooden stick handle tucked underneath the pop body
            GameImage(name: "fjc_stick")
                .frame(width: 34, height: 160)
                .offset(y: 90)

            // Frozen pop
            if bitesTaken < 3 {
                GameImage(name: selectedMold.popAsset)
                    .frame(width: 160, height: 190)
                    .mask(
                        Rectangle()
                            .frame(height: CGFloat(3 - bitesTaken) * 70)
                            .offset(y: CGFloat(bitesTaken) * 30)
                    )

                if hasChocolateDip {
                    GameImage(name: "fjc_dip_choco")
                        .frame(width: 150, height: 95)
                        .offset(y: -45)
                }

                if hasSprinkles {
                    GameImage(name: "ss_bit_sprinkles")
                        .frame(width: 110, height: 60)
                        .offset(y: -40)
                }
            }
        }
        .onTapGesture {
            if bitesTaken < 3 {
                takeBite()
            }
        }
    }

    // MARK: - Controls
    private var step1Controls: some View {
        VStack(spacing: 12) {
            Text("✨ Choose Popsicle Mold:")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.mintDark)

            HStack(spacing: 8) {
                ForEach(PopsicleMold.allCases) { mold in
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        selectedMold = mold
                    }) {
                        VStack(spacing: 4) {
                            Text(mold.emoji)
                                .font(.system(size: 26))
                            Text(mold.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.textDark)
                        }
                        .frame(width: 90, height: 75)
                        .background(selectedMold == mold ? Color.mintGreen.opacity(0.3) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedMold == mold ? Color.mintDark : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation { step = .pourAndStick }
            }) {
                Text("NEXT: POUR JUICE 👉")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.mintDark)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var step2Controls: some View {
        VStack(spacing: 10) {
            Text("🧃 1. Pour Fruit Juice:")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)

            HStack(spacing: 10) {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_pour")
                    selectedJuice = "Red Strawberry"
                    hasJuice = true
                }) {
                    Text("🍓 Strawberry")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 120, height: 36)
                        .background(hasJuice && selectedJuice == "Red Strawberry" ? Color.pinkStrawberry : Color.white)
                        .foregroundColor(hasJuice && selectedJuice == "Red Strawberry" ? .white : .textDark)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.pinkStrawberry, lineWidth: 1.5))
                }

                Button(action: {
                    AudioManager.shared.playSFX("sfx_pour")
                    selectedJuice = "Orange Citrus"
                    hasJuice = true
                }) {
                    Text("🍊 Orange")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 120, height: 36)
                        .background(hasJuice && selectedJuice == "Orange Citrus" ? Color.orange : Color.white)
                        .foregroundColor(hasJuice && selectedJuice == "Orange Citrus" ? .white : .textDark)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.orange, lineWidth: 1.5))
                }
            }

            // Insert stick button
            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                hasStick = true
            }) {
                Text(hasStick ? "✓ 2. WOODEN STICK INSERTED" : "🪵 2. INSERT WOODEN STICK")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(hasStick ? Color.mintGreen : Color(hex: 0xFFBCAAA4))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            if hasJuice && hasStick {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_click")
                    withAnimation { step = .freezeInFreezer }
                }) {
                    Text("3. FREEZE IN FREEZER ❄️")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.blueSky)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var step3Controls: some View {
        VStack(spacing: 12) {
            Text("❄️ Super Turbo Freezer ❄️")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.blueSky)

            Text("Tap button to freeze your popsicle solid and cold!")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)

            Button(action: {
                startFreezing()
            }) {
                Text(isFreezing ? "❄️ FREEZING SOLID..." : "❄️ TURN ON FREEZER")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blueSky)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .disabled(isFreezing)
        }
    }

    private var step4Controls: some View {
        VStack(spacing: 8) {
            Text("🍫 Dip Chocolate & Decorate")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.textDark)

            HStack(spacing: 10) {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_pop")
                    hasChocolateDip.toggle()
                }) {
                    Text(hasChocolateDip ? "✓ Choco Dip" : "🍫 Dip Choco")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 120, height: 34)
                        .background(hasChocolateDip ? Color(hex: 0xFF6D4C41) : Color.white)
                        .foregroundColor(hasChocolateDip ? .white : .textDark)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color(hex: 0xFF6D4C41), lineWidth: 1.5))
                }

                Button(action: {
                    AudioManager.shared.playSFX("sfx_sprinkle")
                    hasSprinkles.toggle()
                }) {
                    Text(hasSprinkles ? "✓ Sprinkles" : "🌈 Sprinkles")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 120, height: 34)
                        .background(hasSprinkles ? Color.pinkStrawberry : Color.white)
                        .foregroundColor(hasSprinkles ? .white : .textDark)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.pinkStrawberry, lineWidth: 1.5))
                }
            }

            Spacer().frame(height: 4)

            Text(bitesTaken < 3 ? "👉 Tap the popsicle to take crispy bites!" : "🎉 Awesome job! Your pet finished it! (+25 Coins)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            if bitesTaken >= 3 {
                Button(action: {
                    resetState()
                }) {
                    Text("Make Another Popsicle 🍭")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.mintGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func startFreezing() {
        AudioManager.shared.playSFX("sfx_freeze")
        isFreezing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isFreezing = false
            isFrozen = true
            withAnimation {
                step = .decorateAndFeed
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
            appState.addCoins(25)
            showCelebration = true
        }
    }

    private func resetState() {
        step = .chooseMold
        hasJuice = false
        hasStick = false
        isFreezing = false
        isFrozen = false
        hasChocolateDip = false
        hasSprinkles = false
        bitesTaken = 0
        showCelebration = false
    }
}

