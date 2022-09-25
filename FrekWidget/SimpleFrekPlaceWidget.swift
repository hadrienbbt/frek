import WidgetKit
import SwiftUI
import SwiftUICharts

struct SimpleFrekPlaceWidget: Widget {
    let kind: String = "FrekWidget.simple"

    var body: some WidgetConfiguration {
        let intentConfiguration = IntentConfiguration(
            kind: kind,
            intent: SelectGymIntent.self,
            provider: SimpleFrekPlaceProvider(),
            content: { SimpleFrekPlaceEntryView(frekPlace: $0.frekPlace) }
        )
#if os(watchOS)
        var supportedFamilies: [WidgetFamily] = []
        if #available(iOSApplicationExtension 16.0, watchOSApplicationExtension 9.0, *) {
            supportedFamilies = [.accessoryCircular, .accessoryInline, .accessoryRectangular, .accessoryCorner]
        }
#else
        var supportedFamilies: [WidgetFamily] = [.systemSmall, .systemLarge]
        if #available(iOSApplicationExtension 16.0, watchOSApplicationExtension 9.0, *) {
            supportedFamilies = [.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemLarge]
        }
#endif
        return intentConfiguration
        .configurationDisplayName("Salle de gym")
        .description("Affiche la fréquentation d'une salle de gym")
        .supportedFamilies(supportedFamilies)
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            print("Widget sessionIdentifier: \(sessionIdentifier)")
        }
        
    }
}

struct SimpleFrekPlaceProvider: IntentTimelineProvider {
    @available(iOSApplicationExtension 16.0, *)
    func recommendations() -> [IntentRecommendation<SelectGymIntent>] {
        let viewModel = FrekPlaceListViewModel()
        return viewModel.frekPlaces
            .filter { $0.favorite }
            .map {
                let intent = SelectGymIntent()
                intent.frekPlace = $0.toGym()
                return IntentRecommendation(intent: intent, description: $0.name)
            }
    }
    
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
#if os(watchOS)
        SmallFrekPlaceEntryView(frekPlace: frekPlace)
            .widgetURL(frekPlace.url)
#else
        if widgetFamily == .systemLarge, let chart = frekPlace.frekCharts.first {
            DetailedFrekPlaceEntryView(frekPlace: frekPlace, frekChart: chart)
                .widgetURL(frekPlace.url)
        } else {
            SmallFrekPlaceEntryView(frekPlace: frekPlace)
                .widgetURL(frekPlace.url)
        }
#endif
    }
}

struct SmallFrekPlaceEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    var frekPlace: FrekPlace
    
    var systemWidget: some View {
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
    
    @State private var current = 67.0
    @State private var minValue = 50.0
    @State private var maxValue = 170.0
    let gradient = Gradient(colors: [.green, .yellow, .red])

    
    @ViewBuilder
    var body: some View {
        if #available(iOSApplicationExtension 16.0, watchOSApplicationExtension 9.0, *) {
            if widgetFamily == .accessoryCircular {
//                ZStack {
//                    AccessoryWidgetBackground()
//                    VStack {
//                        Text(frekPlace.crowd.description)
//                            .font(.title)
//                            .widgetAccentable()
//                        Text("/\(frekPlace.fmi)")
//                            .font(.caption)
//                    }
//                }
                Gauge(value: Double(frekPlace.crowd), in: 0...Double(frekPlace.fmi), label: {
                    Text("\(frekPlace.name)")
                }, currentValueLabel: {
                    Text(frekPlace.crowd.description)
                        .widgetAccentable()
                }).gaugeStyle(.accessoryCircularCapacity)
                
//                Gauge(value: Double(frekPlace.crowd), in: 0...Double(frekPlace.fmi)) {
//                    Image(uiImage: UIImage(named: frekPlace.suffix)!)
//                } currentValueLabel: {
//                    Text("\(frekPlace.crowd)")
//                        .foregroundColor(Color.green)
//                } minimumValueLabel: {
//                    Text("\(frekPlace.name)")
//                        .foregroundColor(Color.green)
//                } maximumValueLabel: {
//                    Text("\(frekPlace.fmi)")
//                        .foregroundColor(Color.red)
//                }
//                .gaugeStyle(.accessoryCircularCapacity)
            } else if widgetFamily == .accessoryRectangular {
                ZStack {
                    AccessoryWidgetBackground()
                    VStack {
                        HStack {
                            Text(frekPlace.name.capitalized)
                                .font(.caption)
                                .widgetAccentable()
                            Gauge(value: Double(frekPlace.crowd), in: 0...Double(frekPlace.fmi), label: {
                                Text("\(frekPlace.name)")
                            }, currentValueLabel: {
                                Text(frekPlace.crowd.description)
                                    .widgetAccentable()
                            }).gaugeStyle(.accessoryLinearCapacity)

                        }
                        Text("\(frekPlace.crowd)/\(frekPlace.fmi)")
                            .font(.title)
                    }
                }
            } else if widgetFamily == .accessoryInline {
                Text("\(frekPlace.name.capitalized) - \(frekPlace.crowd)/\(frekPlace.fmi)")
            } else {
                systemWidget
            }
        } else {
            systemWidget
        }
    }
}

#if os(iOS)

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

#endif
