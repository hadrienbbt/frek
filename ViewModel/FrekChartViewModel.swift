//
//  FrekChartListViewModel.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-06-02.
//

import Foundation
import UIKit
import SwiftUI
import SwiftUICharts

class FrekChartViewModel: ObservableObject {
    
    @Published var chart: FrekChart
    let formatter = FrekFormatter()
    let governmentGauge = 0.5
    
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
        GradientStop(color: .yellow, location: 0.33),
        GradientStop(color: .orange, location: 0.66),
        GradientStop(color: .red, location: 1)
    ]
    
    var smallLineChartData: LineChartData {
        var datapoints: [LineChartDataPoint] = chart.dataset
            .filter { $0 != 0 }
            .map { LineChartDataPoint(value: $0) }
        datapoints.insert(LineChartDataPoint(value: 0), at: 0)
        let data = LineDataSet(
            dataPoints: datapoints,
            style: LineStyle(lineColour: ColourStyle(stops: gradient, startPoint: .bottom, endPoint: .center /*UnitPoint(x: 0, y: CGFloat(chart.fmi) * CGFloat(governmentGauge))*/), lineType: .curvedLine)
        )
        let chartStyle = LineChartStyle(
            topLine: .maximum(of: Double(chart.fmi)),
            globalAnimation: .easeOut(duration: 0.2)
        )
        return LineChartData(dataSets: data, chartStyle: chartStyle)
    }
    
    var detailedLineChartData: MultiLineChartData {
        let frekDataPoints: [LineChartDataPoint] = chart.dataset
            .enumerated()
            .map { LineChartDataPoint(
                value: $0.element,
                xAxisLabel: formatter.string(fromFrekTimeIndex: $0.offset)
            )}
        let frekLineStyle = LineStyle(lineColour: ColourStyle(stops: gradient, startPoint: .bottom, endPoint: .center/*UnitPoint(x: 24, y: CGFloat(chart.fmi) * CGFloat(governmentGauge))*/), lineType: .curvedLine)
        let fmiDataPoints: [LineChartDataPoint] = chart.fmiDataset.map { LineChartDataPoint(value: $0) }
        let fmiLineStyle = LineStyle(lineColour: ColourStyle(colour: .red), lineType: .line)
        let gaugeDataPoints: [LineChartDataPoint] = chart.fmiDataset.map { LineChartDataPoint(value: $0 * governmentGauge) }
        let gaugeLineStyle = LineStyle(lineColour: ColourStyle(colour: .red), lineType: .line, strokeStyle: Stroke(lineWidth: 1, dash: [8], dashPhase: 0))
        let data = MultiLineDataSet(dataSets: [
            LineDataSet(dataPoints: fmiDataPoints, legendTitle: "Max: \(chart.fmi)", style: fmiLineStyle),
            LineDataSet(dataPoints: frekDataPoints, legendTitle: "Fréquentation", style: frekLineStyle),
            LineDataSet(dataPoints: gaugeDataPoints, legendTitle: "Jauge réduite à \(Int(governmentGauge * 100))%", style: gaugeLineStyle),
        ])
        let gridStyle = GridStyle(
            numberOfLines: yAxisLabels.count,
            lineColour: Color(UIColor(red: 40, green: 40, blue: 40, alpha: 1)).opacity(0.5),
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
            topLine: .maximum(of: Double(yAxisLabels.last!)!),
            globalAnimation: .easeOut(duration: 0.5)
        )
        return MultiLineChartData(
            dataSets: data,
            xAxisLabels: xAxisLabels,
            yAxisLabels: yAxisLabels,
            chartStyle: chartStyle
        )
    }
    
    var xAxisLabels: [String] {
        (0...chart.dataset.count)
            .filter { $0 % 6 == 0 }
            .map { $0 != 0 && $0 != 48 ? formatter.string(fromFrekTimeIndex: $0) : " " }
    }
    
    var xAxisLabels2: [String] {
        var period = 2
        var labels = chart.dataset
            .enumerated()
            .map { $0.offset }
        while labels.count > 7 {
            labels = chart.dataset
                .enumerated()
                .filter { $0.offset % period == (period / 2) }
                .map { $0.offset }
            period += 1
        }
        return labels.map { formatter.string(fromFrekTimeIndex: $0) }
    }
    
    var yAxisLabels: [String] {
        let max = round((Double(chart.fmi) / 10)) * 10
        var period = 0.0
        var labels = [String]()
        repeat {
            labels.removeAll()
            var start = 0.0
            period += 10
            repeat {
                labels.append(start.description)
                start += period
            } while start <= max
        } while labels.count > 10
        if let last = labels.last,
           let lastDouble = Double(last),
           lastDouble < max {
            let extraLabel = (lastDouble + period).description
            labels.append(extraLabel)
        }
        return labels
    }
}

extension View {
    public func frekDetailedChart<T>(chartData: T) -> some View where T : CTLineBarChartDataProtocol {
        self
            .xAxisGrid(chartData: chartData)
            .yAxisGrid(chartData: chartData)
            .xAxisLabels(chartData: chartData)
            .yAxisLabels(chartData: chartData)
            .legends(
                chartData: chartData,
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                iconWidth: 30, font: .subheadline,
                textColor: .secondary
            )
    }
}
