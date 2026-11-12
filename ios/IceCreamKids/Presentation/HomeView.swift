import SwiftUI

struct HomeView: View {
    @ObservedObject var appState: AppState
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background
            GameImage(name: "bg_home", contentMode: .fill)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Header Row
                HStack {
                    CoinBadge(coins: appState.coins)
                    Spacer()
                    FreeEditionBadge()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer()

                // Center Column: App Logo, Title, Play Button, Album Button
                VStack(spacing: 10) {
                    GameImage(name: "app_logo")
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3.5))
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                    Text("🍨 ICE CREAM KIDS COOKING 🍦")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.pinkStrawberry)
                        .shadow(color: Color.white, radius: 2, x: 0, y: 1)

                    Text("Fun Ice Cream Cooking Game for Kids")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.textDark.opacity(0.8))

                    Spacer().frame(height: 12)

                    // Big Play Now Button
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_pop")
                        appState.navigate(to: .menu)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("PLAY NOW")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 240, height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: 0xFFFF5252), Color.pinkStrawberry],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.pinkStrawberry.opacity(0.4), radius: 8, x: 0, y: 4)
                        .scaleEffect(pulseScale)
                    }

                    // Baby's Album Button
                    Button(action: {
                        AudioManager.shared.playSFX("sfx_click")
                        appState.navigate(to: .album)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 16, weight: .bold))
                            Text("Baby's Album")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(Color(hex: 0xFF00796B))
                        .frame(width: 200, height: 44)
                        .background(Color.mintGreen.opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            AudioManager.shared.playBGM()
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

