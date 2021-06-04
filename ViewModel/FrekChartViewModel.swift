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
        GradientStop(color: .green, location: 0),
        GradientStop(color: .yellow, location: 0.25),
        GradientStop(color: .orange, location: 0.5),
        GradientStop(color: .red, location: 0.75)
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
        let chartStyle = LineChartStyle(
            topLine: .maximum(of: Double(chart.fmi)),
            globalAnimation: .easeOut(duration: 0.2)
        )
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
            numberOfLines: yAxisLabels.count,
            lineColour: Color(.systemGray5).opacity(0.5),
            lineWidth: 1,
            dash: [8],
            dashPhase: 0
        )
        let chartStyle = LineChartStyle(
            xAxisGridStyle: gridStyle,
            xAxisLabelColour: .secondary,
            xAxisLabelsFrom: .chartData(rotation: Angle(degrees: 0.0)),
            yAxisGridStyle: gridStyle,
            yAxisLabelColour: .secondary,
            yAxisNumberOfLabels: yAxisLabels.count,
            yAxisTitle: "Fréquentation",
            yAxisTitleColour: .secondary,
            topLine: .maximum(of: Double(yAxisLabels.last!)!),
            globalAnimation: .easeOut(duration: 0.5)
        )
        return LineChartData(
            dataSets: data,
            xAxisLabels: xAxisLabels,
            yAxisLabels: yAxisLabels,
            chartStyle: chartStyle
        )
    }
    
    var xAxisLabels: [String] {
        var period = 2
        var labels = chart.dataset
            .enumerated()
            .map { $0.offset }
        while labels.count > 7 {
            labels = chart.dataset
                .enumerated()
                .filter { $0.offset % period == (period / 2) }
                .map { $0.offset }
            period *= 2
        }
        return labels.map { formatter.string(fromFrekTimeIndex: $0) }
    }
    
    var yAxisLabels: [String] {
        var period = 1
        var labels = [String]()
        repeat {
            labels.removeAll()
            var start = 0
            while start < chart.fmi{
                labels.append(start.description)
                start += period * 10
            }
            period += 1
        } while labels.count > 7
        return labels
    }
    
    let fmiExtraLineStyle = ExtraLineStyle(
        lineColour: ColourStyle(colour: .red),
        lineType: .line,
        yAxisTitle: "Max"
    )
        
    var fmiExtraLineDataPoints: [ExtraLineDataPoint] {
        chart.fmiDataset.map { ExtraLineDataPoint(value: $0) }
    }
}
