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
    @State private var showDetail: Bool

    init(_ viewModel: FrekChartViewModel, _ showDetail: Bool) {
        self.viewModel = viewModel
        self._showDetail = State(initialValue: showDetail)
    }
    
    var info: String { viewModel.chart.isOpen ? "Entre \(viewModel.frekStartTime) et \(viewModel.frekEndTime)\nMax: \(viewModel.max) personnes à \(viewModel.maxTime)" : "Fermée" }
    
    let animationDuration = 0.2
    
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
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: animationDuration))
                    .onTapGesture {
                        self.showDetail.toggle()
                    }
            }
            if viewModel.chart.isOpen, showDetail {
                DetailedChart(viewModel: viewModel)
            }
        }
    }
}

struct DetailedChart: View {
    var viewModel: FrekChartViewModel
    
    var body: some View {
        LineChart(chartData: viewModel.detailedLineChartData)
            .frame(height: 250)
            /*.extraLine(
                chartData: viewModel.detailedLineChartData,
                legendTitle: "Max")
                { viewModel.fmiExtraLineDataPoints }
                style: { viewModel.fmiExtraLineStyle }*/
            .xAxisGrid(chartData: viewModel.detailedLineChartData)
            .yAxisGrid(chartData: viewModel.detailedLineChartData)
            .xAxisLabels(chartData: viewModel.detailedLineChartData)
            .yAxisLabels(chartData: viewModel.detailedLineChartData)
            .padding(.leading, -7)
            .padding(.bottom, 5)
    }
}

struct SmallChart: View {
    var data: LineChartData
    
    var body: some View {
        LineChart(chartData: data)
            .frame(width: 50, height: 30)
    }
}
