import SwiftUI

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
                    SmallChart(viewModel: viewModel)
                        .frame(width: 50, height: 30)
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
                    .animation(.easeInOut(duration: animationDuration), value: showDetail)
                    .onTapGesture {
                        self.showDetail.toggle()
                    }
            }
            if viewModel.chart.isOpen, showDetail {
                LargeChart(viewModel: viewModel)
                    .animation(.easeInOut(duration: animationDuration), value: showDetail)
            }
        }
    }
}

struct FrekChartRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FrekPlaceListViewModel()
        let frekplace = viewModel.frekPlaces.last!
        let chartViewModel = FrekChartViewModel(chart: frekplace.frekCharts.last!)
        FrekChartRow(chartViewModel, true)
    }
}
