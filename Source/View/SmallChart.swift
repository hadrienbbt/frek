import SwiftUI
import Charts

struct SmallChart: View {
    var viewModel: FrekChartViewModel

    var body: some View {
        Chart {
            ForEach(viewModel.chart.dayData.filter { $0.frek > 0 }, id: \.time) {
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
            .foregroundStyle(.red.gradient)
            .lineStyle(StrokeStyle(lineWidth: 3))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(width: 50, height: 30)
        .padding()
    }
}

struct SmallChart_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FrekPlaceListViewModel()
        let frekplace = viewModel.frekPlaces.last!
        let chartViewModel = FrekChartViewModel(chart: frekplace.frekCharts.last!)
        SmallChart(viewModel: chartViewModel)
    }
}
