//
//  FrekPlaceList.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceList: View {
    
    @State var frekPlaces: [FrekPlace]
    @State var refreshing: Bool
    let refresh: () -> Void
    
    func createFrekPlaceRow(_ frekPlace: FrekPlace) -> FrekPlaceRow {
        let index = frekPlaces.firstIndex(where: { frekPlace.id == $0.id })!
        return FrekPlaceRow(frekPlace: $frekPlaces[index])
    }
    
    var body: some View {
        let sortedFrekPlaces = frekPlaces.sorted(by: { $0.name < $1.name })
        let favorites = sortedFrekPlaces.filter { $0.favorite }
        
        return NavigationView {
            #if os(iOS)
                List {
                    if favorites.count > 0 {
                        Section(header: Text("Favorites")) {
                            ForEach(favorites) { self.createFrekPlaceRow($0) }
                        }
                    }
                    Section(header: Text("Toutes")) {
                        ForEach(sortedFrekPlaces) { self.createFrekPlaceRow($0) }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle(Text("Salles de gym"))
                .navigationBarItems(
                    trailing: Button(refreshing ? "🔄 Refreshing" : "🔄 Refresh") { self.refresh() }
                        .disabled(refreshing)
                )
            #elseif os(watchOS)
                List {
                    RefreshButton(
                        refreshing: refreshing,
                        refresh: refresh
                    )
                    if favorites.count > 0 {
                        Section(header: Text("Favorites")) {
                            ForEach(favorites) { self.createFrekPlaceRow($0) }
                        }
                    }
                    Section(header: Text("Toutes")) {
                        ForEach(sortedFrekPlaces) { self.createFrekPlaceRow($0) }
                    }
                }
                .listStyle(CarouselListStyle())
                .navigationBarTitle(Text("Salles de gym"))
            #endif
        }
    }
}
