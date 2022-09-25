import SwiftUI
import Charts

struct LargeChart: View {
    var viewModel: FrekChartViewModel

    var body: some View {
        Chart {
            ForEach(viewModel.chart.dayData, id: \.time) {
                LineMark(
                    x: .value("Heure", $0.time, unit: .minute),
                    y: .value("Fréquentation", $0.frek)
                )
                .foregroundStyle(
                    .linearGradient(
                        stops: viewModel.gradientStops,
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .interpolationMethod(.catmullRom)
            }
            RuleMark(
                y: .value("Maximum", viewModel.chart.fmi)
            )
            .foregroundStyle(.red.gradient)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .annotation(position: .top, alignment: .leading) {
                Text("Max: \(viewModel.chart.fmi, format: .number)")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute)) { value in
                if let date = value.as(Date.self),
                    date.isFullHour,
                    date.isEvenHour,
                    !date.isMidnight {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .abbreviated)))

                }
            }
        }
        .frame(height: 250)
        .padding()
    }
}

struct LargeChart_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FrekPlaceListViewModel()
        let frekplace = viewModel.frekPlaces.last!
        let chartViewModel = FrekChartViewModel(chart: frekplace.frekCharts.last!)
        LargeChart(viewModel: chartViewModel)
    }
}
