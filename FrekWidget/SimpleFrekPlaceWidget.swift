//
//  File.swift
//  FrekWidgetExtension
//
//  Created by Hadrien Barbat on 27/10/2021.
//

import WidgetKit
import SwiftUI
import SwiftUICharts

struct SimpleFrekPlaceWidget: Widget {
    let kind: String = "FrekWidget.simple"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectGymIntent.self, provider: SimpleFrekPlaceProvider()) { entry in
            SimpleFrekPlaceEntryView(frekPlace: entry.frekPlace)
        }
        .configurationDisplayName("Salle de gym")
        .description("Affiche la fréquentation d'une salle de gym")
        .supportedFamilies([.systemSmall, .systemLarge])
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            print("Widget sessionIdentifier: \(sessionIdentifier)")
        }
    }
}

struct SimpleFrekPlaceProvider: IntentTimelineProvider {
    typealias Entry = SimpleFrekPlaceEntry
    typealias Intent = SelectGymIntent
    
    func placeholder(in context: Context) -> SimpleFrekPlaceEntry {
        let viewModel = FrekPlaceListViewModel()
        let frekPlace = viewModel.favorites.randomElement() ?? FrekPlace.sample1
        return SimpleFrekPlaceEntry(date: Date(), frekPlace: frekPlace)
    }
    
    func getSnapshot(for configuration: SelectGymIntent, in context: Context, completion: @escaping (SimpleFrekPlaceEntry) -> Void) {
        let viewModel = FrekPlaceListViewModel()
        let frekPlace = viewModel.frekPlaces.first(where: { $0.id == configuration.frekPlace?.identifier }) ?? viewModel.frekPlaces.randomElement() ?? FrekPlace.sample1
        completion(SimpleFrekPlaceEntry(date: Date(), frekPlace: frekPlace))
    }
    
    func getTimeline(for configuration: SelectGymIntent, in context: Context, completion: @escaping (Timeline<SimpleFrekPlaceEntry>) -> Void) {
        let viewModel = FrekPlaceListViewModel()
        viewModel.fetchFrekPlaces {
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let frekPlace = viewModel.frekPlaces.first(where: { $0.id == configuration.frekPlace?.identifier }) ?? viewModel.frekPlaces.randomElement() ?? FrekPlace.sample1
            let entry = SimpleFrekPlaceEntry(date: Date(), frekPlace: frekPlace)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleFrekPlaceEntry: TimelineEntry {
    var date: Date
    let frekPlace: FrekPlace
}

struct SimpleFrekPlaceEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    var frekPlace: FrekPlace
    
    var body: some View {
        if widgetFamily == .systemLarge, let chart = frekPlace.frekCharts.first {
            DetailedFrekPlaceEntryView(frekPlace: frekPlace, frekChart: chart)
        } else {
            SmallFrekPlaceEntryView(frekPlace: frekPlace)
        }
    }
}

struct SmallFrekPlaceEntryView: View {
    var frekPlace: FrekPlace
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image(self.frekPlace.suffix)
                    .resizable()
                    .frame(width: geo.size.width)
            }
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(self.frekPlace.name)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .bold()
                Text("\(self.frekPlace.crowd.description)/\(self.frekPlace.fmi)")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(.clear)
            .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
        }
    }
}

struct DetailedFrekPlaceEntryView: View {
    var frekPlace: FrekPlace
    var frekChart: FrekChart
        
    var body: some View {
        let viewModel = FrekChartViewModel(chart: frekChart)
        VStack {
            FrekPlaceRow(frekPlace: frekPlace)
            MultiLineChart(chartData: viewModel.detailedLineChartData)
                .frekDetailedChart(chartData: viewModel.detailedLineChartData, withLegend: false)
        }
        .padding()
    }
}
