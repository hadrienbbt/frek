//
//  FrekChart.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-05-30.
//

import Foundation
import SwiftUI
import SwiftUICharts

struct FrekChart: Identifiable, Decodable, Encodable {
    var id = UUID()
    let date: Date
    let starts: [Int]
    let ends: [Int]
    let fmi: Int
    
    static func decode(_ dict: Dict, _ fmi: Int) -> FrekChart? {
        guard let date = FrekFormatter().parseISOString(dict["day"]),
              let start = dict["start"] as? [Int],
              let end = dict["end"] as? [Int] else {
            print("❌ Error parsing FrekChart dictionnary")
            return nil
        }
        
        
        return FrekChart(date: date, starts: start, ends: end, fmi: fmi)
    }
    
    func getLineChart() -> LineChart<LineChartData> {
        let formatter = FrekFormatter()
        
        let frekData: [LineChartDataPoint] = self.starts
            .enumerated()
            .reduce([]) { acc, val in
                let (index, element) = val
                var newAcc = acc
                newAcc.append(Double(element))
                if ends.count > index {
                    newAcc.append(Double(ends[index]))
                }
                return newAcc
            }
            .map {
                LineChartDataPoint(value: $0)
            }
        // let fmiData = frekData.map { _ in Double(self.fmi) }
        
        let data = LineDataSet(
            dataPoints: frekData,
            legendTitle: "Steps",
            pointStyle: PointStyle(),
            style: LineStyle(lineColour: ColourStyle(colour: .red), lineType: .curvedLine)
        )
        
        let metadata = ChartMetadata(title: formatter.string(from: date), subtitle: "Subtitle")
        
        let gridStyle  = GridStyle(
            numberOfLines: 7,
            lineColour: Color(.lightGray).opacity(0.5),
            lineWidth: 1,
            dash: [8],
            dashPhase: 0
        )
        
        let chartStyle = LineChartStyle(
            infoBoxPlacement: .infoBox(isStatic: false),
            markerType: .vertical(attachment: .line(dot: .style(DotStyle()))),
            xAxisGridStyle: gridStyle,
            xAxisLabelPosition: .bottom,
            xAxisLabelColour: Color.primary,
            xAxisLabelsFrom: .dataPoint(rotation: .degrees(0)),
            yAxisGridStyle: gridStyle,
            yAxisLabelPosition: .leading,
            yAxisLabelColour: Color.primary,
            yAxisNumberOfLabels: 7,
            baseline: .minimumValue,
            topLine: .maximumValue,
            globalAnimation: .easeOut(duration: 1)
        )
        
        let chartData = LineChartData(
            dataSets: data,
            metadata: metadata,
            chartStyle: chartStyle
        )
        
        return LineChart(chartData: chartData)
    }
}

class FrekFormatter: Formatter {
    let isoFormatter = ISO8601DateFormatter()
    let dateFormatter = DateFormatter()
    let relativeFormatter = RelativeDateTimeFormatter()
    
    func parseISOString(_ isoString: Any?) -> Date? {
        guard let isoString = isoString as? String else {
            print("❌ Error parsing iso string")
            return nil
        }
        return isoFormatter.date(from: isoString)
    }
    
    func string(from date: Date) -> String {
        print("Locale")
        print(Locale.current)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdEEEE")
        return dateFormatter.string(from: date)
    }
}
