import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .landscape
    }
}

@main
struct IceCreamKidsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appState.currentScreen {
                case .home:
                    HomeView(appState: appState)
                case .menu:
                    MenuSelectView(appState: appState)
                case .softServe:
                    SoftServeView(appState: appState)
                case .gelato:
                    GelatoView(appState: appState)
                case .popsicle:
                    PopsicleView(appState: appState)
                case .sweetIce:
                    SweetIceView(appState: appState)
                case .milkshake:
                    MilkshakeView(appState: appState)
                case .album:
                    CandyAlbumView(appState: appState)
                }
            }
            .statusBar(hidden: true)
        }
    }
}
