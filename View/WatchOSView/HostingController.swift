//
//  HostingController.swift
//  FrekWatch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<FrekApp> {
    override var body: FrekApp {
        return FrekApp()
    }
}
