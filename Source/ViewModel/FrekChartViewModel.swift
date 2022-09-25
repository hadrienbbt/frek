import Foundation
import UIKit
import SwiftUI

class FrekChartViewModel: ObservableObject {
    
    @Published var chart: FrekChart
    let formatter = FrekFormatter()
    
    init(chart: FrekChart) {
        self.chart = chart
    }
    
    var formattedDate: String {
        return formatter.string(fromChartDate: chart.date)
    }
    
    var max: String {
        guard let max = chart.dataset.max() as NSNumber? else { return "" }
        return formatter.string(fromNumber: max)
    }
    
    var maxTime: String {
        guard let max = chart.dataset.max(),
              let maxIndex = chart.dataset.firstIndex(where: { $0 == max }) else {
            return ""
        }
        return formatter.string(fromFrekTimeIndex: maxIndex)
    }
    
    var frekStartTime: String {
        guard let openIndex = chart.dataset.firstIndex(where: { $0 != 0 }) else {
            return ""
        }
        return formatter.string(fromFrekTimeIndex: openIndex)
    }
    
    var frekEndTime: String {
        guard let closeIndex = chart.dataset.lastIndex(where: { $0 != 0 }) else {
            return ""
        }
        return formatter.string(fromFrekTimeIndex: closeIndex)
    }
    let gradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: .green, location: 0),
        Gradient.Stop(color: .yellow, location: 0.33),
        Gradient.Stop(color: .orange, location: 0.66),
        Gradient.Stop(color: .red, location: 1),
    ]
}
