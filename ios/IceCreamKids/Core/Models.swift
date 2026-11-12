import SwiftUI
import Combine

enum AppScreen {
    case home
    case menu
    case softServe
    case gelato
    case popsicle
    case sweetIce
    case milkshake
    case album
}

enum AnimalType: String, CaseIterable, Identifiable {
    case panda = "Panda"
    case fox = "Little Fox"
    case puppy = "Puppy"
    case kitty = "Cute Kitty"
    case bunny = "Little Bunny"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .panda: return "🐼"
        case .fox: return "🦊"
        case .kitty: return "🐱"
        case .bunny: return "🐰"
        case .puppy: return "🐶"
        }
    }

    var orderEmoji: String {
        switch self {
        case .panda: return "🍦"
        case .fox: return "🍨"
        case .kitty: return "🥤"
        case .bunny: return "🍭"
        case .puppy: return "🧊"
        }
    }

    var avatarAssetName: String {
        switch self {
        case .panda: return "animal_panda"
        case .fox: return "animal_fox"
        case .kitty: return "animal_kitty"
        case .bunny: return "animal_bunny"
        case .puppy: return "animal_puppy"
        }
    }
}

enum DessertType: String, CaseIterable, Identifiable {
    case softServe = "Soft Serve"
    case scoopCup = "Scoop Cup"
    case popsicle = "Popsicle"
    case sweetIce = "Sweet Ice"
    case milkshake = "Milkshake"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .softServe: return "Pull & swirl"
        case .scoopCup: return "4 yummy scoops"
        case .popsicle: return "Freeze fruit pop"
        case .sweetIce: return "Tap & pop dish"
        case .milkshake: return "Fruit smoothie"
        }
    }

    var machineAsset: String {
        switch self {
        case .softServe: return "select_machine_ss"
        case .scoopCup: return "select_machine_icb"
        case .popsicle: return "select_machine_fjc"
        case .sweetIce: return "select_machine_si"
        case .milkshake: return "select_machine_d"
        }
    }

    var themeColor: Color {
        switch self {
        case .softServe: return .pinkStrawberry
        case .scoopCup: return Color(hex: 0xFFFFB74D)
        case .popsicle: return Color(hex: 0xFF26A69A)
        case .sweetIce: return Color(hex: 0xFF42A5F5)
        case .milkshake: return .yellowMango
        }
    }
}

final class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .home
    @Published var coins: Int = 100
    @Published var selectedAnimal: AnimalType = .panda

    func navigate(to screen: AppScreen) {
        AudioManager.shared.playSFX("sfx_click")
        withAnimation(.easeInOut(duration: 0.25)) {
            currentScreen = screen
        }
    }

    func addCoins(_ amount: Int) {
        coins += amount
    }
}

