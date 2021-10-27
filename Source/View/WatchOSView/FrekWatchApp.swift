import SwiftUI

@main
struct FrekWatchApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            FrekPlaceList()
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
