//
//  FrekWidget.swift
//  FrekWidget
//
//  Created by Hadrien Barbat on 23/10/2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    let frekPlaceListViewModel = FrekPlaceListViewModel()
    
    func placeholder(in context: Context) -> FrekEntry {
        return FrekEntry(date: Date(), frekPlace: frekPlaceListViewModel.frekPlaces.first?.encode())
    }

    func getSnapshot(for configuration: SelectGymIntent, in context: Context, completion: @escaping (FrekEntry) -> ()) {
        let entry = FrekEntry(date: Date(), frekPlace: frekPlaceListViewModel.frekPlaces.first?.encode())
        completion(entry)
    }

    func getTimeline(for configuration: SelectGymIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        frekPlaceListViewModel.fetchFrekPlaces { frekPlaces in
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let entries = frekPlaces.map { FrekEntry(date: currentDate, frekPlace: $0.encode()) }
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct FrekEntry: TimelineEntry {
    var date: Date
    let frekPlace: Gym?
}

struct FrekWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let frekPlace = entry.frekPlace,
              let suffix = frekPlace.suffix,
              let crowd = frekPlace.crowd,
              let fmi = frekPlace.fmi {
            ZStack {
                GeometryReader { geo in
                    Image(suffix)
                        .resizable()
                        .frame(width: geo.size.width)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    Text(frekPlace.displayString)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .bold()
                    Text("\(crowd.description)/\(fmi)")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.clear)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
            }
        } else {
            Text("No Frekplace")
        }
    }
}

@main
struct FrekWidget: Widget {
    let kind: String = "FrekWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectGymIntent.self, provider: Provider()) { entry in
            FrekWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Salles de gym")
        .description("Fréquentation des salles de gym en temps réel")
    }
}
