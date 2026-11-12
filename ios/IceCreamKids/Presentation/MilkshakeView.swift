import SwiftUI

enum MilkshakeStep {
    case addIngredients
    case blend
    case pourToCup
    case addWhipAndStraw
    case drinkAndFeed
}

enum BlenderFruit: String, CaseIterable, Identifiable {
    case strawberry = "Strawberry"
    case banana = "Banana"
    case blueberry = "Blueberry"
    case orange = "Orange"
    case watermelon = "Watermelon"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .strawberry: return "🍓"
        case .banana: return "🍌"
        case .blueberry: return "🫐"
        case .orange: return "🍊"
        case .watermelon: return "🍉"
        }
    }

    var chunkAsset: String {
        switch self {
        case .strawberry: return "d_fruit_strawberry_pile"
        case .banana: return "d_fruit_banana_pile"
        case .blueberry: return "d_fruit_blueberry_pile"
        case .orange: return "d_fruit_orange_pile"
        case .watermelon: return "d_fruit_watermelon_pile"
        }
    }

    var drinkAsset: String {
        switch self {
        case .strawberry: return "d_drink_strawberry"
        case .banana: return "d_drink_banana"
        case .blueberry: return "d_drink_blueberry"
        case .orange: return "d_drink_orange"
        case .watermelon: return "d_drink_watermelon"
        }
    }

    var color: Color {
        switch self {
        case .strawberry: return Color(hex: 0xFFFF4081)
        case .banana: return Color(hex: 0xFFFFD54F)
        case .blueberry: return Color(hex: 0xFF7E57C2)
        case .orange: return Color(hex: 0xFFFF9800)
        case .watermelon: return Color(hex: 0xFFFF5252)
        }
    }
}

struct MilkshakeView: View {
    @ObservedObject var appState: AppState

    @State private var step: MilkshakeStep = .addIngredients
    @State private var addedFruits: [BlenderFruit] = []
    @State private var hasMilk: Bool = false
    @State private var bladeAngle: Double = 0
    @State private var isBlending: Bool = false
    @State private var hasWhippedCream: Bool = false
    @State private var hasSprinkles: Bool = false
    @State private var selectedStraw: Int = 1
    @State private var drinkLevel: Int = 3
    @State private var showCelebration: Bool = false
    @State private var animalMood: AnimalMood = .waiting

    var stepTitle: String {
        switch step {
        case .addIngredients: return "🥛 STEP 1: ADD FRUITS & FRESH MILK! 🍓"
        case .blend: return "🌪️ STEP 2: BLENDER IS SPINNING... 🌪️"
        case .pourToCup: return "🥤 STEP 3: POUR MILKSHAKE INTO GLASS! 🌈"
        case .addWhipAndStraw: return "🍦 STEP 4: WHIPPED CREAM & PARTY STRAW! 🍒"
        case .drinkAndFeed: return "😋 STEP 5: TAP GLASS TO FEED YOUR PET! 🐱"
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
                    // Left: Blender or Serving Cup Stage
                    ZStack {
                        if step == .addIngredients || step == .blend {
                            blenderStageView
                        } else {
                            glassCupServingStageView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Control Panels
                    VStack {
                        switch step {
                        case .addIngredients:
                            step1ControlsView
                        case .blend:
                            step2ControlsView
                        case .pourToCup:
                            step3ControlsView
                        case .addWhipAndStraw:
                            step4ControlsView
                        case .drinkAndFeed:
                            step5ControlsView
                        }
                    }
                    .frame(width: 310)
                    .padding(14)
                    .background(Color.white.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.pinkLight.opacity(0.4), lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }

            ConfettiView(isActive: showCelebration)
        }
    }

    // MARK: - Blender Stage (Pixel-Perfect 100% Collar-Locked Native Composite)
    private var blenderStageView: some View {
        let s: CGFloat = 195.0 / 540.0 // Native scale = 0.36111
        let ox: CGFloat = 15.2 // Centers collar and jar on screen

        return ZStack(alignment: .topLeading) {
            // 1. Jar Back Glass: centered on collar (200 - 234 = -34)
            GameImage(name: "d_blender_back")
                .frame(width: 468 * s, height: 496 * s)
                .offset(x: ox - 34 * s, y: 42 * s)

            // 2. Liquid inside Jar: official d_blender_liquid asset tinted with fruit/milk color
            if hasMilk || step == .blend || !addedFruits.isEmpty {
                GameImage(name: "d_blender_liquid", tint: liquidColor.opacity(hasMilk ? 0.90 : 0.65))
                    .frame(width: 468 * s, height: 496 * s)
                    .offset(x: ox - 34 * s, y: 42 * s)
            }

            // 3. Floating Fruit Pieces (centered on collar, swirling inside pitcher)
            if !addedFruits.isEmpty {
                ZStack {
                    ForEach(Array(addedFruits.enumerated()), id: \.offset) { index, fruit in
                        let xOff: CGFloat = index == 0 ? -22 : (index == 1 ? 22 : (index == 2 ? -12 : 14))
                        let yOff: CGFloat = index == 0 ? -14 : (index == 1 ? -6 : (index == 2 ? 14 : 10))
                        GameImage(name: fruit.asset)
                            .frame(width: step == .blend ? 26 : 38, height: step == .blend ? 26 : 38)
                            .offset(x: xOff, y: yOff)
                    }
                }
                .frame(width: 300 * s, height: 240 * s)
                .offset(x: ox + 50 * s, y: 140 * s)
                .rotationEffect(.degrees(step == .blend ? bladeAngle : 0))
            }

            // 4. Blender Base & Motor Body + Pitcher Handle (540 x 772 native at 0,0)
            GameImage(name: "d_blender_base")
                .frame(width: 540 * s, height: 772 * s)
                .offset(x: ox, y: 0)

            // 5. Rotary Blade: native centered at collarX (200 - 44 = 156), y = 330
            GameImage(name: "blender_blade")
                .frame(width: 88 * s, height: 88 * s)
                .rotationEffect(.degrees(bladeAngle))
                .offset(x: ox + 156 * s, y: 330 * s)

            // 6. Jar Front Glass: centered on collarX (200 - 242 = -42)
            GameImage(name: "d_blender_front")
                .frame(width: 484 * s, height: 512 * s)
                .offset(x: ox - 42 * s, y: 35 * s)

            // 7. Blender Lid on Top: seated tightly on jar rim (-42, -15)
            GameImage(name: "d_blender_lid")
                .frame(width: 484 * s, height: 140 * s)
                .offset(x: ox - 42 * s, y: -15 * s)

            // 8. Power Button on Motor Base: centered at collarX (200 - 40 = 160), y = 520
            Button(action: {
                if (!addedFruits.isEmpty || hasMilk) && step != .blend {
                    startBlending()
                }
            }) {
                GameImage(name: "d_blender_button")
                    .frame(width: 80 * s, height: 82 * s)
                    .scaleEffect(step == .blend ? 0.90 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: ox + 160 * s, y: 520 * s)
        }
        .frame(width: 211, height: 285)
        .offset(x: step == .blend ? CGFloat.random(in: -2...2) : 0)
    }

    // MARK: - Glass Cup Serving Stage
    private var glassCupServingStageView: some View {
        HStack(spacing: 20) {
            // Customer Animal
            VStack {
                AnimalCustomerView(animalType: appState.selectedAnimal, mood: animalMood, size: 130)
                Text(appState.selectedAnimal.rawValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.textDark)
            }

            // Glass Cup with sealed whipped cream rim
            ZStack {
                // Glass Back
                GameImage(name: "d_glass_back")
                    .frame(width: 150, height: 210)

                // Smoothie Liquid
                if step != .pourToCup || drinkLevel > 0 {
                    let drink = addedFruits.last?.drinkAsset ?? "d_drink_strawberry"
                    GameImage(name: drink)
                        .frame(width: 125, height: CGFloat(drinkLevel) * 55)
                        .offset(y: CGFloat(3 - drinkLevel) * 18 + 15)
                }

                // Glass Front
                GameImage(name: "d_glass_front")
                    .frame(width: 150, height: 210)

                // Party Straw
                let straw = "d_decor_straw_\(selectedStraw)"
                GameImage(name: straw)
                    .frame(width: 42, height: 150)
                    .offset(x: 15, y: -75)

                // Whipped Cream Rim - tightly sealed across glass rim
                if hasWhippedCream {
                    GameImage(name: "swirl_vanilla_bottom")
                        .frame(width: 155, height: 100)
                        .offset(y: -75)

                    GameImage(name: "swirl_vanilla_top")
                        .frame(width: 110, height: 95)
                        .offset(x: 8, y: -115)

                    if hasSprinkles {
                        GameImage(name: "ss_bit_sprinkles")
                            .frame(width: 80, height: 45)
                            .offset(x: 8, y: -110)
                    }
                }
            }
            .onTapGesture {
                if step == .drinkAndFeed && drinkLevel > 0 {
                    drinkBite()
                }
            }
        }
    }

    private var liquidColor: Color {
        addedFruits.last?.color ?? Color.pinkStrawberry
    }

    // MARK: - Controls
    private var step1ControlsView: some View {
        VStack(spacing: 8) {
            Text("🍉 Add Fruit Chunks (\(addedFruits.count)/4):")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            HStack(spacing: 4) {
                ForEach(BlenderFruit.allCases) { fruit in
                    Button(action: {
                        addFruit(fruit)
                    }) {
                        VStack(spacing: 2) {
                            Text(fruit.emoji).font(.system(size: 20))
                            Text(fruit.rawValue).font(.system(size: 8, weight: .bold)).foregroundColor(.textDark)
                        }
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(fruit.color, lineWidth: 1.5))
                    }
                }
            }

            Spacer().frame(height: 4)

            Button(action: {
                AudioManager.shared.playSFX("sfx_pour")
                hasMilk = true
            }) {
                Text(hasMilk ? "✓ 2. FRESH MILK ADDED" : "🥛 2. POUR FRESH MILK")
                    .font(.system(size: 12, weight: .bold))
                    .frame(maxWidth: .infinity).frame(height: 36)
                    .background(hasMilk ? Color.mintGreen : Color.blueSky)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            if !addedFruits.isEmpty && hasMilk {
                Button(action: {
                    startBlendingAction()
                }) {
                    Text("3. START BLENDING ▶")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Color.pinkStrawberry)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var step2ControlsView: some View {
        VStack(spacing: 12) {
            Text("🌪️ Blender Is Spinning...")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .pinkStrawberry))
                .scaleEffect(1.3)
        }
    }

    private var step3ControlsView: some View {
        VStack(spacing: 10) {
            Text("✨ Smoothie Blended Smooth!")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            Button(action: {
                AudioManager.shared.playSFX("sfx_pour")
                withAnimation { step = .addWhipAndStraw }
            }) {
                Text("POUR INTO GLASS CUP 🥤")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity).frame(height: 42)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var step4ControlsView: some View {
        VStack(spacing: 8) {
            Text("🍒 Choose Straw & Decorate:")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { straw in
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        selectedStraw = straw
                    }) {
                        Text("Straw \(straw)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(selectedStraw == straw ? .white : .textDark)
                            .frame(width: 80, height: 32)
                            .background(selectedStraw == straw ? Color.pinkStrawberry : Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.pinkStrawberry, lineWidth: 1.5))
                    }
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                hasWhippedCream.toggle()
            }) {
                Text(hasWhippedCream ? "✓ Whipped Cream" : "🍦 Add Whipped Cream")
                    .font(.system(size: 11, weight: .bold))
                    .frame(maxWidth: .infinity).frame(height: 34)
                    .background(hasWhippedCream ? Color.mintGreen : Color(hex: 0xFFFFF9C4))
                    .foregroundColor(.textDark)
                    .clipShape(Capsule())
            }

            if hasWhippedCream {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_sprinkle")
                    hasSprinkles.toggle()
                }) {
                    Text(hasSprinkles ? "✓ Rainbow Sprinkles" : "🌈 Add Sprinkles")
                        .font(.system(size: 11, weight: .bold))
                        .frame(maxWidth: .infinity).frame(height: 34)
                        .background(hasSprinkles ? Color.mintGreen : Color(hex: 0xFFFCE4EC))
                        .foregroundColor(.textDark)
                        .clipShape(Capsule())
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation {
                    step = .drinkAndFeed
                    animalMood = .waiting
                }
            }) {
                Text("SERVE TO PET! 😋")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity).frame(height: 38)
                    .background(Color.pinkStrawberry)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var step5ControlsView: some View {
        VStack(spacing: 8) {
            Text(drinkLevel > 0 ? "👉 Tap the glass to feed your pet!" : "🎉 Awesome! Smoothie loved! (+25 Coins)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            if drinkLevel == 0 {
                Button(action: {
                    resetState()
                }) {
                    Text("Make Another Smoothie 🔄")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Color.mintGreen)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func addFruit(_ fruit: BlenderFruit) {
        guard addedFruits.count < 4 else { return }
        AudioManager.shared.playSFX("sfx_splash")
        addedFruits.append(fruit)
    }

    private func startBlendingAction() {
        AudioManager.shared.playSFX("sfx_click")
        step = .blend
        isBlending = true

        withAnimation(.linear(duration: 0.15).repeatCount(15, autoreverses: false)) {
            bladeAngle = 360 * 6
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            isBlending = false
            withAnimation {
                step = .pourToCup
            }
        }
    }

    private func drinkBite() {
        AudioManager.shared.playSFX("sfx_yummy")
        animalMood = .eating
        withAnimation {
            drinkLevel -= 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if drinkLevel <= 0 {
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
        step = .addIngredients
        addedFruits = []
        hasMilk = false
        hasWhippedCream = false
        hasSprinkles = false
        drinkLevel = 3
        showCelebration = false
        animalMood = .waiting
    }
}
