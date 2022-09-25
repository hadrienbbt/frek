import Foundation
import SwiftUI

typealias Dict = [String: Any]

extension View {
   @ViewBuilder
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

extension UIColor {
    static var chartGrid = UIColor(red: 150, green: 150, blue: 150, alpha: 0.5)
}

extension Date {
    var isFullHour: Bool {
        let comps = Calendar.current.dateComponents([.minute, .second], from: self)
        return comps.minute == 0 && comps.second == 0
    }
    
    var isEvenHour: Bool {
        let comps = Calendar.current.dateComponents([.hour], from: self)
        guard let hours = comps.hour else { return false}
        return hours % 4 == 0
    }
    
    var isMidnight: Bool {
        if !isFullHour { return false }
        let comps = Calendar.current.dateComponents([.hour], from: self)
        guard let hours = comps.hour else { return false}
        return hours == 0
    }
}
