import Foundation
import SwiftUI

struct FrekChart: Identifiable, Decodable, Encodable {
    var id = UUID()
    let dataset: [Double]
    let date: Date
    let fmi: Int
    
    var isOpen: Bool { dataset.contains { $0 != 0 } }
    var fmiDataset: [Double] { dataset.map { _ in Double(fmi) }}
}
