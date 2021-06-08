//
//  FrekPlaceList.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceList: View {
    
    @ObservedObject var viewModel = FrekPlaceListViewModel()
    
    func createFrekPlaceRow(_ id: String) -> NavigationLink<FrekPlaceRow, FrekPlaceDetail> {
        let index = viewModel.frekPlaces.firstIndex(where: { id == $0.id })!
        return NavigationLink(destination: FrekPlaceDetail(frekPlace: $viewModel.frekPlaces[index])) {
            FrekPlaceRow(frekPlace: $viewModel.frekPlaces[index])
        }
    }
    
    var body: some View {
        let favorites = viewModel.favorites
        let sortedFrekPlaces = viewModel.sortedFrekPlaces
        
        return NavigationView {
            #if os(iOS)
                List {
                    if favorites.count > 0 {
                        Section(header: Text("Favorites")) {
                            ForEach(favorites) { self.createFrekPlaceRow($0.id)
                            }
                        }
                    }
                    Section(header: Text("Toutes")) {
                        ForEach(sortedFrekPlaces) { self.createFrekPlaceRow($0.id) }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle(Text("Salles de gym"))
            #elseif os(watchOS)
                List {
                    if favorites.count > 0 {
                        Section(header: Text("Favorites")) {
                            ForEach(favorites) { self.createFrekPlaceRow($0.id) }
                        }
                    }
                    Section(header: Text("Toutes")) {
                        ForEach(sortedFrekPlaces) { self.createFrekPlaceRow($0.id) }
                    }
                }
                .listStyle(CarouselListStyle())
                .navigationBarTitle(Text("Salles de gym"))
            #endif
        }
        .onAppear { viewModel.fetchFrekPlaces() }
    }
}
