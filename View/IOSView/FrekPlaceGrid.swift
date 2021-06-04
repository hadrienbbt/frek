//
//  FrekPlaceGrid.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-28.
//

import SwiftUI

struct FrekPlaceGrid: View {
    @ObservedObject var viewModel = FrekPlaceListViewModel()

    var columns: [GridItem] {
        var columns = [GridItem(spacing: 50), GridItem(spacing: 50)]
        if !DeviceMeta().isPortrait { columns.append(GridItem(spacing: 50)) }
        return columns
    }
    
    func createFrekPlaceRow(_ id: String) -> NavigationLink<FrekPlaceRow, FrekPlaceDetail> {
        let index = viewModel.frekPlaces.firstIndex(where: { id == $0.id })!
        return NavigationLink(destination: FrekPlaceDetail(frekPlace: $viewModel.frekPlaces[index])) {
            FrekPlaceRow(frekPlace: $viewModel.frekPlaces[index])
        }
    }
    
    var body: some View {
        let sortedFrekPlaces = viewModel.frekPlaces.sorted(by: { $0.name < $1.name })
        let favorites = sortedFrekPlaces.filter { $0.favorite }
        
        ScrollView {
            if favorites.count > 0 {
                Section(header: Text("Favorites")) {
                    LazyVGrid(columns: columns, spacing: 50) {
                        ForEach(favorites) { self.createFrekPlaceRow($0.id) }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .padding()
                }
                .padding()
            }
            Section(header: Text("Toutes")) {
                LazyVGrid(columns: columns, spacing: 50) {
                    ForEach(sortedFrekPlaces) { self.createFrekPlaceRow($0.id) }
                }
                .listStyle(InsetListStyle())
                .padding()
            }
            .padding()
         }
    }
}
