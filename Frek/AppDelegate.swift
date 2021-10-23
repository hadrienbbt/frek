//
//  AppDelegate.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-05-21.
//

import Foundation
import UIKit
#if os(iOS)
// import Firebase
#endif

class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if os(iOS)
        // FirebaseApp.configure()
    #endif
    return true
  }
}
