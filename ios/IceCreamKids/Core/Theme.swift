import SwiftUI
import UIKit

// MARK: - App Color Palette
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }

    static let pinkStrawberry = Color(hex: 0xFFFF4081)
    static let pinkLight = Color(hex: 0xFFFF80AB)
    static let pinkSoft = Color(hex: 0xFFFCE4EC)
    static let mintGreen = Color(hex: 0xFF69F0AE)
    static let mintDark = Color(hex: 0xFF00BFA5)
    static let vanillaCream = Color(hex: 0xFFFFF9C4)
    static let yellowMango = Color(hex: 0xFFFFD54F)
    static let orangePeach = Color(hex: 0xFFFFAB91)
    static let blueSky = Color(hex: 0xFF81D4FA)
    static let textDark = Color(hex: 0xFF2D3142)
    static let textMuted = Color(hex: 0xFF757575)
    static let tableWood = Color(hex: 0xFFD7CCC8)
}

// MARK: - Game Image Loader
struct GameImage: View {
    let name: String
    var contentMode: ContentMode = .fit

    var body: some View {
        if let uiImg = loadImage(named: name) {
            Image(uiImage: uiImg)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            // Graceful fallback for missing assets
            Rectangle()
                .fill(Color.gray.opacity(0.15))
        }
    }

    private func loadImage(named name: String) -> UIImage? {
        if let img = UIImage(named: name) {
            return img
        }
        if let path = Bundle.main.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        // Check subfolder Resources/Assets
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Assets") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

