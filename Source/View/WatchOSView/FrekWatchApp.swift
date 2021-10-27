import SwiftUI

@main
struct FrekWatchApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                FrekPlaceList()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
