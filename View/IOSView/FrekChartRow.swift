//
//  FrekChartRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-06-02.
//

import SwiftUI
import SwiftUICharts

struct FrekChartRow: View {
    @ObservedObject var viewModel: FrekChartViewModel
    @State private var showDetail = false

    var info: String { viewModel.chart.isOpen ? "Entre \(viewModel.frekStartTime) et \(viewModel.frekEndTime)\nMax: \(viewModel.max) personnes à \(viewModel.maxTime)" : "Fermée" }
    
    var textBlock: some View {
        VStack(alignment: .leading) {
            Text(viewModel.formattedDate)
                .font(.headline)
                .foregroundColor(.primary)
                .fixedSize()
            Text(info)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize()
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
    
    var body: some View {
        Divider()
        VStack(alignment: .leading) {
            HStack {
                if viewModel.chart.isOpen, !showDetail {
                    SmallChart(data: viewModel.smallLineChartData)
                }
                textBlock
                if viewModel.chart.isOpen {
                    Spacer()
                    Image(systemName: "chevron.right.circle")
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetail ? 90 : 0))
                        .padding(.trailing)
                        .foregroundColor(.blue)
                }
            }
            .if(viewModel.chart.isOpen) { stack in
                stack
                    .contentShape(Rectangle())
                    .onTapGesture {
                    withAnimation(Animation.easeInOut(duration: 0.2)) { self.showDetail.toggle() }
                }
            }
            if viewModel.chart.isOpen, showDetail {
                DetailedChart(chart: viewModel.chart, data: viewModel.detailedLineChartData)
            }
        }
    }
}

struct DetailedChart: View {
    var chart: FrekChart
    var data: LineChartData
    
    var body: some View {
        LineChart(chartData: data)
            .extraLine(
                chartData: data,
                legendTitle: "Max",
                datapoints: { [ExtraLineDataPoint(value: Double(chart.fmi))] },
                style: { ExtraLineStyle() }
            )
            .frame(height: 200)
            .padding()
    }
}

struct SmallChart: View {
    var data: LineChartData
    
    var body: some View {
        LineChart(chartData: data)
            .frame(width: 50, height: 30)
    }
}
