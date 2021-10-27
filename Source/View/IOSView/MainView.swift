import SwiftUI

@main
struct MainView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        return WindowGroup {
            FrekPlaceList()
        }
    }
}
