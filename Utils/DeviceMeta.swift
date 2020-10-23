//
//  DeviceMeta.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-22.
//

import Foundation
import SwiftUI

class DeviceMeta {
    var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    var isPortrait: Bool { UIDevice.current.orientation.isPortrait }
}
