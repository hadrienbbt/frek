//
//  FrekChartListViewModel.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-06-02.
//

import Foundation
import SwiftUI
import SwiftUICharts

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
    
    let gradient = [
        GradientStop(color: Color.green, location: 0),
        GradientStop(color: Color.yellow, location: 0.5),
        GradientStop(color: Color.red, location: 1)
    ]
    
    var smallLineChartData: LineChartData {
        var datapoints: [LineChartDataPoint] = chart.dataset
            .filter { $0 != 0 }
            .map { LineChartDataPoint(value: $0) }
        datapoints.insert(LineChartDataPoint(value: 0), at: 0)
        let data = LineDataSet(
            dataPoints: datapoints,
            style: LineStyle(lineColour: ColourStyle(stops: gradient, startPoint: .bottom, endPoint: .top), lineType: .curvedLine)
        )
        let chartStyle = LineChartStyle(globalAnimation: .easeOut(duration: 0.2))
        return LineChartData(dataSets: data, chartStyle: chartStyle)
    }
    
    var detailedLineChartData: LineChartData {
        let datapoints: [LineChartDataPoint] = chart.dataset
            .enumerated()
            .map { LineChartDataPoint(
                value: $0.element,
                xAxisLabel: formatter.string(fromFrekTimeIndex: $0.offset)
            )}
        let data = LineDataSet(
            dataPoints: datapoints,
            style: LineStyle(lineColour: ColourStyle(stops: gradient, startPoint: .bottom, endPoint: .top), lineType: .curvedLine)
        )
        let gridStyle = GridStyle(
            numberOfLines: 7,
            lineColour: Color(.lightGray).opacity(0.5),
            lineWidth: 1,
            dash: [8],
            dashPhase: 0
        )
        let chartStyle = LineChartStyle(
            xAxisGridStyle: gridStyle,
            yAxisGridStyle: gridStyle,
            globalAnimation: .easeOut(duration: 0.5)
        )
        return LineChartData(dataSets: data, chartStyle: chartStyle)
            
    }
    /*
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
 */
}
