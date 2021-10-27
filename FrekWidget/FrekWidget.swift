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
        FavoriteFrekPlaceWidget()
    }
}

struct SimpleFrekPlaceWidget: Widget {
    let kind: String = "FrekWidget.simple"

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
    
    func placeholder(in context: Context) -> SimpleFrekPlaceEntry {
        return getEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleFrekPlaceEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleFrekPlaceEntry>) -> ()) {
        let viewModel = FrekPlaceListViewModel()
        viewModel.fetchFrekPlaces {
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let entries = viewModel.sortedFrekPlaces.map { SimpleFrekPlaceEntry(date: currentDate, frekPlace: $0) }
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    func getEntry() -> SimpleFrekPlaceEntry {
        let viewModel = FrekPlaceListViewModel()
        guard let frekPlace = viewModel.favorites.randomElement() else {
            return SimpleFrekPlaceEntry(date: Date(), frekPlace: FrekPlace.sample1)
        }
        return SimpleFrekPlaceEntry(date: Date(), frekPlace: frekPlace)
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

struct FavoriteFrekPlaceWidget: Widget {
    let kind: String = "FrekWidget.favorite"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoriteFrekPlaceProvider()) { entry in
            FavoriteFrekPlaceEntryView(frekPlaces: entry.frekPlaces)
        }
        .configurationDisplayName("Salle de gym favorites")
        .description("Affiche la fréquentation des salles de gym favorites")
        .supportedFamilies([.systemLarge])
        .onBackgroundURLSessionEvents { (sessionIdentifier, completion) in
            print("Widget sessionIdentifier: \(sessionIdentifier)")
        }
    }
}

struct FavoriteFrekPlaceProvider: TimelineProvider {

    func placeholder(in context: Context) -> FavoriteFrekPlaceEntry {
        return getEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoriteFrekPlaceEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoriteFrekPlaceEntry>) -> ()) {
        let viewModel = FrekPlaceListViewModel()
        viewModel.fetchFrekPlaces {
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let entry = getEntry()
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    func getEntry() -> FavoriteFrekPlaceEntry {
        let viewModel = FrekPlaceListViewModel()
        let frekPlaces: [FrekPlace]
        if !viewModel.favorites.isEmpty {
            frekPlaces = Array(viewModel.favorites.prefix(3))
        } else if !viewModel.sortedFrekPlaces.isEmpty {
            frekPlaces = Array(viewModel.sortedFrekPlaces.prefix(3))
        } else {
            frekPlaces = Array(FrekPlace.samples.prefix(3))
        }
        return FavoriteFrekPlaceEntry(date: Date(), frekPlaces: frekPlaces)
    }
}


struct FavoriteFrekPlaceEntry: TimelineEntry {
    var date: Date
    let frekPlaces: [FrekPlace]
}

struct FavoriteFrekPlaceEntryView: View {
    var frekPlaces: [FrekPlace]
    
    var body: some View {
        ForEach(frekPlaces) { frekPlace in
            HStack {
                FrekThumbnail(name: frekPlace.suffix)
                    .padding([.leading], 20)
                VStack(alignment: .leading) {
                    Text(frekPlace.name)
                        .font(.headline)
                    Text(frekPlace.isOpen ? "Ouverte" : "Fermée")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Max: \(frekPlace.fmi)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 5)
                Spacer()
                if frekPlace.isOpen {
                    VStack {
                        Text(frekPlace.crowd.description)
                            .font(.title)
                        Text("Personnes\nsur place")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding([.trailing], 20)
                }
            }
        }
    }
}
