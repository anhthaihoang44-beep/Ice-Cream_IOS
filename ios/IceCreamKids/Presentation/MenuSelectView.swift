import SwiftUI

struct MenuSelectView: View {
    @ObservedObject var appState: AppState
    @State private var cardScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Official Kitchen Background matching Android
            GameImage(name: "bg_kitchen", contentMode: .fill)
                .ignoresSafeArea()

            // Soft white wash for readable buttons
            Color.white.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Header: Back button + Title + Animal Customer Switcher
                HStack(spacing: 12) {
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        appState.navigate(to: .home)
                    }) {
                        GameImage(name: "btn_back")
                            .frame(width: 46, height: 46)
                    }

                    Spacer()

                    Text("🌟 CHOOSE A YUMMY DESSERT TO MAKE! 🌟")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.pinkStrawberry)

                    Spacer()

                    // Animal Switcher Pills
                    HStack(spacing: 5) {
                        ForEach(AnimalType.allCases) { animal in
                            Button(action: {
                                AudioManager.shared.playSFX("sfx_click")
                                appState.selectedAnimal = animal
                            }) {
                                Text(animal.emoji)
                                    .font(.system(size: 18))
                                    .frame(width: 36, height: 36)
                                    .background(appState.selectedAnimal == animal ? Color.pinkStrawberry : Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(
                                            appState.selectedAnimal == animal ? Color.pinkStrawberry : Color.pinkLight.opacity(0.5),
                                            lineWidth: 2
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Main Content: Left = Animal Customer, Right = 5 Dessert Recipe Stations
                HStack(spacing: 12) {
                    // Left: Animal customer with Order Bubble & Animated Canvas
                    VStack(spacing: 6) {
                        OrderBubbleView(
                            desiredDessertEmoji: appState.selectedAnimal.orderEmoji,
                            message: "I'm hungry! Let's cook a yummy treat!"
                        )

                        Spacer().frame(height: 4)

                        // Animated Vector Chibi Animal matching Android Canvas!
                        AnimalCustomerView(
                            animalType: appState.selectedAnimal,
                            mood: .waiting,
                            size: 125
                        )

                        Text(appState.selectedAnimal.rawValue)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.textDark)
                    }
                    .frame(width: 170)

                    // Right: 5 Dessert Stations with Official Machine Drawables
                    HStack(spacing: 8) {
                        StationCard(
                            drawableName: "select_machine_ss",
                            title: "Soft Serve",
                            subtitle: "Pull & swirl",
                            color: .pinkStrawberry,
                            scale: cardScale,
                            action: { appState.navigate(to: .softServe) }
                        )

                        StationCard(
                            drawableName: "select_machine_icb",
                            title: "Scoop Cup",
                            subtitle: "4 yummy scoops",
                            color: Color(hex: 0xFFFFB74D),
                            scale: 1.0,
                            action: { appState.navigate(to: .gelato) }
                        )

                        StationCard(
                            drawableName: "select_machine_fjc",
                            title: "Popsicle",
                            subtitle: "Freeze fruit pop",
                            color: .mintGreen,
                            scale: 1.0,
                            action: { appState.navigate(to: .popsicle) }
                        )

                        StationCard(
                            drawableName: "select_machine_si",
                            title: "Sweet Ice",
                            subtitle: "Tap & pop dish",
                            color: Color(hex: 0xFF4FC3F7),
                            scale: 1.0,
                            action: { appState.navigate(to: .sweetIce) }
                        )

                        StationCard(
                            drawableName: "select_machine_d",
                            title: "Milkshake",
                            subtitle: "Fruit smoothie",
                            color: .yellowMango,
                            scale: 1.0,
                            action: { appState.navigate(to: .milkshake) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                cardScale = 1.03
            }
        }
    }
}

struct StationCard: View {
    let drawableName: String
    let title: String
    let subtitle: String
    let color: Color
    var scale: CGFloat = 1.0
    let action: () -> Void

    var body: some View {
        Button(action: {
            AudioManager.shared.playSFX("sfx_pop")
            action()
        }) {
            VStack(spacing: 6) {
                Spacer().frame(height: 8)

                // Circle with official machine artwork
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.85), lineWidth: 3)
                        .background(Circle().fill(Color.white))
                        .frame(width: 82, height: 82)

                    GameImage(name: drawableName)
                        .frame(width: 72, height: 72)
                }

                Spacer()

                Text(title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.textDark)

                Text(subtitle)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.textMuted)

                Spacer().frame(height: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.85), lineWidth: 2.5)
            )
            .shadow(color: color.opacity(0.2), radius: 5, x: 0, y: 3)
            .scaleEffect(scale)
        }
    }
}
