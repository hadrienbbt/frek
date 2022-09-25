import Foundation
import SwiftUI

struct FrekChart: Identifiable, Decodable, Encodable, Hashable {
    var id = UUID()
    let dataset: [Double]
    let date: Date
    let fmi: Int
    
    var isOpen: Bool { dataset.contains { $0 != 0 } }
    var fmiDataset: [Double] { dataset.map { _ in Double(fmi) } }
    
    var dayData: [(time: Date, frek: Double)] {
        let formatter = FrekFormatter()
        return dataset
            .enumerated()
            .map { (index, frek) in (
                time: formatter.date(
                    fromFrekTimeIndex: index,
                    for: date),
                frek: frek
            )}
    }
}
