import Foundation
import SwiftUI

public enum Platform: Int {
    case unspecified = -1
    case phone = 0
    case pad = 1
    case tv = 2
    case carPlay = 3
    case mac = 5
    case vision = 6
}

class DeviceMeta {
#if os(iOS)
    var idiom: Platform { Platform(rawValue: UIDevice.current.userInterfaceIdiom.rawValue) ?? .unspecified }
#elseif os(macOS)
    var idiom: Platform = .mac
#endif
    
    var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
          return true
        #else
          return false
        #endif
    }
    
    var isWatchOS: Bool {
        #if os(watchOS)
            return true
        #else
            return false
        #endif
    }
    
    var isTestFlight: Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else { return false }
        return path.contains("sandboxReceipt")
    }
    
    var isTest: Bool {
        return isTestFlight || isDebug
    }
}
