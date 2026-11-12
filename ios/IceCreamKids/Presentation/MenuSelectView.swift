import SwiftUI

struct MenuSelectView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            // Background
            Color(hex: 0xFFFFFBE6)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Top Header Bar
                HStack(spacing: 12) {
                    Button(action: {
                        appState.navigate(to: .home)
                    }) {
                        GameImage(name: "btn_back")
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("🌟 CHOOSE A YUMMY DESSERT TO MAKE! 🌟")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.pinkStrawberry)

                    Spacer()

                    // Animal Selector Pills
                    HStack(spacing: 6) {
                        ForEach(AnimalType.allCases) { animal in
                            Button(action: {
                                AudioManager.shared.playSFX("sfx_click")
                                appState.selectedAnimal = animal
                            }) {
                                Text(animal.emoji)
                                    .font(.system(size: 20))
                                    .frame(width: 38, height: 38)
                                    .background(appState.selectedAnimal == animal ? Color.pinkStrawberry : Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(
                                            appState.selectedAnimal == animal ? Color.pinkStrawberry : Color.pinkLight.opacity(0.5),
                                            lineWidth: 2
                                        )
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Main Content: Left Customer + Right 5 Dessert Cards
                HStack(spacing: 14) {
                    // Left Column: Animal Customer & Bubble
                    VStack(spacing: 6) {
                        // Order Speech Bubble
                        HStack(spacing: 6) {
                            Text(appState.selectedAnimal.orderEmoji)
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("I'm hungry!")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.textDark)
                                Text("Let's cook a yummy treat!")
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(.textMuted)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.pinkStrawberry, lineWidth: 2))
                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 2)

                        Spacer().frame(height: 6)

                        // Animal Avatar
                        Text(appState.selectedAnimal.emoji)
                            .font(.system(size: 68))
                            .frame(width: 100, height: 100)
                            .background(Color.white.opacity(0.85))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.pinkLight.opacity(0.4), lineWidth: 3))

                        Text(appState.selectedAnimal.rawValue)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.textDark)
                    }
                    .frame(width: 160)

                    // Right: 5 Recipe Cards
                    HStack(spacing: 10) {
                        DessertCard(
                            dessert: .softServe,
                            action: { appState.navigate(to: .softServe) }
                        )
                        DessertCard(
                            dessert: .scoopCup,
                            action: { appState.navigate(to: .gelato) }
                        )
                        DessertCard(
                            dessert: .popsicle,
                            action: { appState.navigate(to: .popsicle) }
                        )
                        DessertCard(
                            dessert: .sweetIce,
                            action: { appState.navigate(to: .sweetIce) }
                        )
                        DessertCard(
                            dessert: .milkshake,
                            action: { appState.navigate(to: .milkshake) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }
}

struct DessertCard: View {
    let dessert: DessertType
    let action: () -> Void

    var body: some View {
        Button(action: {
            AudioManager.shared.playSFX("sfx_pop")
            action()
        }) {
            VStack(spacing: 8) {
                Spacer().frame(height: 10)

                // Circle with official machine artwork
                ZStack {
                    Circle()
                        .stroke(dessert.themeColor.opacity(0.8), lineWidth: 3)
                        .background(Circle().fill(Color.white))
                        .frame(width: 86, height: 86)

                    GameImage(name: dessert.machineAsset)
                        .frame(width: 76, height: 76)
                }

                Spacer()

                Text(dessert.rawValue)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.textDark)

                Text(dessert.subtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.textMuted)

                Spacer().frame(height: 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(dessert.themeColor.opacity(0.85), lineWidth: 3)
            )
            .shadow(color: dessert.themeColor.opacity(0.2), radius: 6, x: 0, y: 3)
        }
    }
}
