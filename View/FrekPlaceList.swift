//
//  FrekPlaceList.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceList: View {
    @Environment(\.imageCache) var cache: ImageCache
    @State var frekPlaces: [FrekPlace]
    @State var refreshing = false
    let refresh: () -> Void
    
    func refreshFrekPlaces() {
        refreshing = true
        refresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            refreshing = false
        }
    }
    
    func createFrekPlaceRow(_ frekPlace: FrekPlace) -> FrekPlaceRow {
        let index = frekPlaces.firstIndex(where: { frekPlace.id == $0.id })!
        return FrekPlaceRow(
            frekPlace: $frekPlaces[index],
            image: AsyncImage(url: frekPlace.image, placeholder: Text("⏳"), cache: cache) { $0.resizable() }
        )
    }
    
    var body: some View {
        #if os(iOS)
            return list
                .listStyle(InsetGroupedListStyle())
                .navigationBarItems(
                    trailing: Button(refreshing ? "🔄 Refreshing" : "Refresh") { self.refresh() }
                        .disabled(refreshing)
                )
        #elseif os(watchOS)
            return list
                .listStyle(CarouselListStyle())
        #endif
    }
    
    var list: some View {
        let sortedFrekPlaces = frekPlaces.sorted(by: { $0.name < $1.name })
        let favorites = sortedFrekPlaces.filter { $0.favorite }
        
        return NavigationView {
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
            .navigationBarTitle(Text("Salles de gym"))
        }
    }
}
