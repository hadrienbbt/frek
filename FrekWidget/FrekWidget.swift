//
//  FrekWidget.swift
//  FrekWidget
//
//  Created by Hadrien Barbat on 23/10/2021.
//

import WidgetKit
import SwiftUI

@main
struct FrekBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        SimpleFrekPlaceWidget()
    }
}

struct SimpleFrekPlaceWidget: Widget {
    let kind: String = "FrekWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleFrekPlaceProvider()) { entry in
            SimpleFrekPlaceEntryView(frekPlace: entry.frekPlace)
        }
        .configurationDisplayName("Salle de gym")
        .description("Affiche la fréquentation d'une salle de gym")
        .supportedFamilies([.systemSmall])
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            print("Widget sessionIdentifier: \(sessionIdentifier)")
        }
    }
}

struct SimpleFrekPlaceProvider: TimelineProvider {
    let frekPlaceListViewModel = FrekPlaceListViewModel()
    
    func placeholder(in context: Context) -> SimpleFrekPlaceEntry {
        return SimpleFrekPlaceEntry(date: Date(), frekPlace: FrekPlace.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleFrekPlaceEntry) -> ()) {
        let entry = SimpleFrekPlaceEntry(date: Date(), frekPlace: FrekPlace.sample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleFrekPlaceEntry>) -> ()) {
        frekPlaceListViewModel.fetchFrekPlaces { frekPlaces in
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let entries = frekPlaces.map { SimpleFrekPlaceEntry(date: currentDate, frekPlace: $0) }
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleFrekPlaceEntry: TimelineEntry {
    var date: Date
    let frekPlace: FrekPlace
}

struct SimpleFrekPlaceEntryView: View {
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
