//
//  FavoriteFrekPlaceWidget.swift
//  FrekWidgetExtension
//
//  Created by Hadrien Barbat on 27/10/2021.
//

import WidgetKit
import SwiftUI

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
