//
//  FrekPlaceList.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceList: View {
    
    @ObservedObject var viewModel = FrekPlaceListViewModel()
    @State private var selectedId: String? = nil
    
    func createFrekPlaceRow(_ id: String) -> NavigationLink<FrekPlaceRow, FrekPlaceDetail> {
        let index = viewModel.frekPlaces.firstIndex(where: { id == $0.id })!
        return NavigationLink(destination: FrekPlaceDetail(frekPlace: $viewModel.frekPlaces[index]), tag: id, selection: $selectedId) {
            FrekPlaceRow(frekPlace: $viewModel.frekPlaces[index])
        }
    }
    
    func onOpenURL(_ url: URL) {
        guard let host = url.host,
              let frekPlace = viewModel.frekPlaces.first(where: { $0.id == host })
        else {
            print("❌ Unsupported deep link: \(url)")
            return
        }
        selectedId = frekPlace.id
    }
    
    var body: some View {
        let favorites = viewModel.favorites
        let other = viewModel.sortedFrekPlaces.filter { !$0.favorite }
        
        return NavigationView {
            #if os(iOS)
                List {
                    if favorites.count > 0 {
                        Section(header: Text("Favorites")) {
                            ForEach(favorites) { self.createFrekPlaceRow($0.id) }
                        }
                    }
                    Section(header: Text("Toutes")) {
                        ForEach(other) { self.createFrekPlaceRow($0.id) }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle(Text("Salles de gym"))
                .onOpenURL(perform: onOpenURL)
            #elseif os(watchOS)
                List {
                    if favorites.count > 0 {
                        Section(header: Text("Favorites")) {
                            ForEach(favorites) { self.createFrekPlaceRow($0.id) }
                        }
                    }
                    Section(header: Text("Toutes")) {
                        ForEach(other) { self.createFrekPlaceRow($0.id) }
                    }
                }
                .listStyle(CarouselListStyle())
                .navigationBarTitle(Text("Salles de gym"))
            #endif
        }
        .onAppear { viewModel.fetchFrekPlaces() }
    }
}
