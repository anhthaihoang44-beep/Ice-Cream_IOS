import SwiftUI

struct AlbumCardItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let artworkAsset: String
    let themeColor: Color
}

struct CandyAlbumView: View {
    @ObservedObject var appState: AppState
    @State private var selectedCard: AlbumCardItem? = nil

    let albumCards: [AlbumCardItem] = [
        AlbumCardItem(
            id: 1,
            title: "Soft Serve Cone",
            subtitle: "Drizzled with strawberry & sprinkles!",
            artworkAsset: "select_machine_ss",
            themeColor: .pinkStrawberry
        ),
        AlbumCardItem(
            id: 2,
            title: "Gelato 3-Scoop Cone",
            subtitle: "Crispy waffle with 3 delicious scoops!",
            artworkAsset: "select_machine_icb",
            themeColor: Color(hex: 0xFFFFB74D)
        ),
        AlbumCardItem(
            id: 3,
            title: "Fruit Popsicle",
            subtitle: "Frozen fruit juice dipped in chocolate!",
            artworkAsset: "select_machine_fjc",
            themeColor: Color(hex: 0xFF26A69A)
        ),
        AlbumCardItem(
            id: 4,
            title: "Sweet Ice Dessert Dish",
            subtitle: "Fruit milk ice cubes tumbling in bowl!",
            artworkAsset: "select_machine_si",
            themeColor: Color(hex: 0xFF42A5F5)
        ),
        AlbumCardItem(
            id: 5,
            title: "Fruit Milkshake Glass",
            subtitle: "Smoothie topped with whipped cream & straw!",
            artworkAsset: "select_machine_d",
            themeColor: .yellowMango
        )
    ]

    var body: some View {
        ZStack {
            // Background
            Color(hex: 0xFFFCE4EC)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Top Header
                GameTopBar(
                    title: "📷 BABY'S SWEET MEMORY ALBUM 🍨",
                    onBack: { appState.navigate(to: .home) }
                )

                // 5 Polaroid Cards Row
                HStack(spacing: 12) {
                    ForEach(albumCards) { card in
                        Button(action: {
                            AudioManager.shared.playSFX("sfx_pop")
                            selectedCard = card
                        }) {
                            VStack(spacing: 6) {
                                // Polaroid Photo Area
                                ZStack {
                                    Color(hex: 0xFFFFFDE7)
                                        .frame(height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    GameImage(name: card.artworkAsset)
                                        .frame(width: 90, height: 90)
                                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                }

                                Text(card.title)
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundColor(.textDark)
                                    .lineLimit(1)

                                Text(card.subtitle)
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(.textMuted)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)

                                Spacer()

                                Text("⭐ FAVORITE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(card.themeColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(card.themeColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(card.themeColor.opacity(0.5), lineWidth: 2))
                            .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }

            // Detail Polaroid Pop-up Dialog
            if let card = selectedCard {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { selectedCard = nil }

                    VStack(spacing: 12) {
                        GameImage(name: card.artworkAsset)
                            .frame(width: 140, height: 140)

                        Text(card.title)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.pinkStrawberry)

                        Text(card.subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.textMuted)

                        Button(action: {
                            AudioManager.shared.playSFX("sfx_click")
                            selectedCard = nil
                        }) {
                            Text("CLOSE")
                                .font(.system(size: 13, weight: .bold))
                                .frame(width: 120, height: 36)
                                .background(Color.pinkStrawberry)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 12)
                }
            }
        }
    }
}

