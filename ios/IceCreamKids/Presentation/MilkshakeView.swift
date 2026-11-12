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
        case .strawberry: return "d_fruit_strawberry"
        case .banana: return "d_fruit_banana_pile"
        case .blueberry: return "d_fruit_blueberry"
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

    var stepTitle: String {
        switch step {
        case .addIngredients: return "🥛 STEP 1: ADD FRUITS & POUR FRESH MILK! 🍓"
        case .blend: return "🌪️ STEP 2: BLENDER IS SPINNING SMOOTHLY... 🌪️"
        case .pourToCup: return "🥤 STEP 3: POUR MILKSHAKE INTO THE GLASS! 🌈"
        case .addWhipAndStraw: return "🍦 STEP 4: ADD WHIPPED CREAM & PARTY STRAW! 🍒"
        case .drinkAndFeed: return "😋 STEP 5: TAP GLASS TO FEED YOUR PET! 🐱"
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
                HStack(spacing: 24) {
                    // Left: Blender or Glass Cup
                    ZStack {
                        if step == .addIngredients || step == .blend {
                            blenderView
                        } else {
                            glassCupView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Right: Control Panels
                    VStack {
                        switch step {
                        case .addIngredients:
                            step1IngredientControls
                        case .blend:
                            step2BlendingControls
                        case .pourToCup:
                            step3PourControls
                        case .addWhipAndStraw:
                            step4DecorateControls
                        case .drinkAndFeed:
                            step5FeedControls
                        }
                    }
                    .frame(width: 320)
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

    // MARK: - Blender View
    private var blenderView: some View {
        ZStack {
            // Blender Body
            GameImage(name: "d_blender_body")
                .frame(width: 210, height: 260)

            // Blending liquid color inside pitcher
            if !addedFruits.isEmpty {
                RoundedRectangle(cornerRadius: 18)
                    .fill(liquidColor.opacity(hasMilk ? 0.85 : 0.65))
                    .frame(width: 130, height: hasMilk ? 110 : 80)
                    .offset(y: 10)
            }

            // Blade
            GameImage(name: "d_blender_blade")
                .frame(width: 46, height: 46)
                .offset(y: 50)
                .rotationEffect(.degrees(bladeAngle))

            // Blender Lid
            GameImage(name: "d_blender_lid")
                .frame(width: 140, height: 38)
                .offset(y: -115)

            // Power button
            GameImage(name: "d_btn_start")
                .frame(width: 40, height: 40)
                .offset(y: 92)
        }
    }

    // MARK: - Glass Cup View
    private var glassCupView: some View {
        ZStack {
            // Glass Back
            GameImage(name: "d_glass_back")
                .frame(width: 160, height: 230)

            // Smoothie Liquid inside glass
            if step != .pourToCup || drinkLevel > 0 {
                let drinkAsset = addedFruits.last?.drinkAsset ?? "d_drink_strawberry"
                GameImage(name: drinkAsset)
                    .frame(width: 130, height: CGFloat(drinkLevel) * 60)
                    .offset(y: CGFloat(3 - drinkLevel) * 20 + 20)
            }

            // Glass Front
            GameImage(name: "d_glass_front")
                .frame(width: 160, height: 230)

            // Straw
            let strawAsset = "d_straw_\(selectedStraw)"
            GameImage(name: strawAsset)
                .frame(width: 45, height: 160)
                .offset(x: 15, y: -90)

            // Whipped Cream Rim (sealed perfectly across glass rim!)
            if hasWhippedCream {
                GameImage(name: "swirl_vanilla_bottom")
                    .frame(width: 162, height: 110)
                    .offset(y: -80)

                GameImage(name: "swirl_vanilla_top")
                    .frame(width: 120, height: 110)
                    .offset(x: 10, y: -130)

                if hasSprinkles {
                    GameImage(name: "ss_bit_sprinkles")
                        .frame(width: 90, height: 50)
                        .offset(x: 10, y: -125)
                }
            }
        }
        .onTapGesture {
            if step == .drinkAndFeed && drinkLevel > 0 {
                drinkOneBite()
            }
        }
    }

    private var liquidColor: Color {
        addedFruits.last?.color ?? Color.pinkStrawberry
    }

    // MARK: - Controls Panels
    private var step1IngredientControls: some View {
        VStack(spacing: 10) {
            Text("🍉 Add Fruit Chunks (\(addedFruits.count)/4)")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            // Fruit Buttons
            HStack(spacing: 6) {
                ForEach(BlenderFruit.allCases) { fruit in
                    Button(action: {
                        addFruit(fruit)
                    }) {
                        VStack(spacing: 2) {
                            Text(fruit.emoji)
                                .font(.system(size: 24))
                            Text(fruit.rawValue)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.textDark)
                        }
                        .frame(width: 54, height: 58)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(fruit.color, lineWidth: 2))
                    }
                }
            }

            Spacer().frame(height: 6)

            // Pour Milk Button
            Button(action: {
                AudioManager.shared.playSFX("sfx_pour")
                hasMilk = true
            }) {
                HStack {
                    Text(hasMilk ? "✓ 2. FRESH MILK ADDED" : "🥛 2. POUR FRESH MILK")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(hasMilk ? Color.mintGreen : Color.blueSky)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }

            // Start Blending Button
            if !addedFruits.isEmpty && hasMilk {
                Button(action: {
                    startBlending()
                }) {
                    Text("3. START BLENDING ▶")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.pinkStrawberry)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var step2BlendingControls: some View {
        VStack(spacing: 12) {
            Text("🌪️ Blender Is Spinning...")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            Text("Fruits and fresh milk are blending together smoothly!")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .pinkStrawberry))
                .scaleEffect(1.4)
                .padding(.top, 8)
        }
    }

    private var step3PourControls: some View {
        VStack(spacing: 12) {
            Text("✨ Smoothie Is Blended Smooth!")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            Button(action: {
                AudioManager.shared.playSFX("sfx_pour")
                withAnimation {
                    step = .addWhipAndStraw
                }
            }) {
                HStack(spacing: 8) {
                    Text("🥤")
                    Text("Pour Into Glass Cup")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.pinkStrawberry)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
    }

    private var step4DecorateControls: some View {
        VStack(spacing: 8) {
            Text("🍒 Choose Straw & Decorate")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.pinkStrawberry)

            // Straw selector
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

            // Whipped cream button
            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                hasWhippedCream.toggle()
            }) {
                HStack {
                    Text(hasWhippedCream ? "✓ Whipped Cream" : "🍦 Add Whipped Cream")
                        .font(.system(size: 12, weight: .bold))
                }
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(hasWhippedCream ? Color.mintGreen : Color(hex: 0xFFFFF9C4))
                .foregroundColor(.textDark)
                .clipShape(Capsule())
            }

            // Sprinkles button
            if hasWhippedCream {
                Button(action: {
                    AudioManager.shared.playSFX("sfx_sprinkle")
                    hasSprinkles.toggle()
                }) {
                    Text(hasSprinkles ? "✓ Rainbow Sprinkles" : "🌈 Add Sprinkles")
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(hasSprinkles ? Color.mintGreen : Color(hex: 0xFFFCE4EC))
                        .foregroundColor(.textDark)
                        .clipShape(Capsule())
                }
            }

            Button(action: {
                AudioManager.shared.playSFX("sfx_pop")
                withAnimation {
                    step = .drinkAndFeed
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

    private var step5FeedControls: some View {
        VStack(spacing: 8) {
            Text(appState.selectedAnimal.emoji)
                .font(.system(size: 40))

            Text(drinkLevel > 0 ? "👉 Tap the glass to feed your pet!" : "🎉 Awesome! Your pet loved it! (+25 Coins)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)

            if drinkLevel == 0 {
                Button(action: {
                    resetState()
                }) {
                    Text("Make Another Smoothie 🔄")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
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

    private func startBlending() {
        AudioManager.shared.playSFX("sfx_click")
        withAnimation {
            step = .blend
            isBlending = true
        }

        withAnimation(.linear(duration: 0.15).repeatCount(15, autoreverses: false)) {
            bladeAngle = 360 * 6
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            isBlending = false
            withAnimation {
                step = .pourToCup
            }
        }
    }

    private func drinkOneBite() {
        AudioManager.shared.playSFX("sfx_yummy")
        withAnimation {
            drinkLevel -= 1
        }
        if drinkLevel == 0 {
            AudioManager.shared.playSFX("sfx_celebrate")
            appState.addCoins(25)
            showCelebration = true
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
    }
}
