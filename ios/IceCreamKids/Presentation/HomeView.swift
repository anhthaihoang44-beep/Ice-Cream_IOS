import SwiftUI

struct HomeView: View {
    @ObservedObject var appState: AppState
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Official Candy Land High-Res Background
            GameImage(name: "bg_candyland", contentMode: .fill)
                .ignoresSafeArea()

            // Soft pastel overlay for clarity matching Android
            Color.white.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Header Row: Coin Badge + 100% Free Edition Badge
                HStack {
                    CoinBadge(coins: appState.coins)
                    Spacer()
                    FreeEditionBadge()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer()

                // Center Column: App Logo, Title, Play Button, Album Button
                VStack(spacing: 8) {
                    GameImage(name: "app_logo")
                        .frame(width: 105, height: 105)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3.5))
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)

                    Spacer().frame(height: 6)

                    Text("🍨 ICE CREAM KIDS COOKING 🍦")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.pinkStrawberry)
                        .shadow(color: Color.white.opacity(0.8), radius: 2, x: 0, y: 1)

                    Text("Fun Ice Cream Cooking Game for Kids")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.textDark.opacity(0.75))

                    Spacer().frame(height: 18)

                    // Big Pulsing Play Button
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_pop")
                        appState.navigate(to: .menu)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            Text("PLAY")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 260, height: 72)
                        .background(Color.pinkStrawberry)
                        .clipShape(Capsule())
                        .shadow(color: Color.pinkStrawberry.opacity(0.45), radius: 10, x: 0, y: 5)
                        .scaleEffect(pulseScale)
                    }

                    Spacer().frame(height: 8)

                    // Album Button
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        appState.navigate(to: .album)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textDark)
                            Text("ALBUM")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.textDark)
                        }
                        .frame(width: 220, height: 52)
                        .background(Color.mintGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            AudioManager.shared.playBGM()
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
    }
}
