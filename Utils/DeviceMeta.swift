import Foundation
import SwiftUI

class DeviceMeta {
    #if os(iOS)
        var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
        var isPortrait: Bool { UIDevice.current.orientation.isPortrait }
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
