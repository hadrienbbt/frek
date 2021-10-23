//
//  FrekApp.swift
//  FrekWatch WatchKit Extension
//
//  Created by Hadrien Barbat on 23/10/2021.
//

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
