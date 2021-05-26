//
//  ToggleFavoriteButton.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-22.
//

import SwiftUI
import ClockKit

struct ToggleFavoriteButton: View {
    var id: String
    @Binding var isFavorite: Bool
    
    func toggleFavorite() -> Bool {
        var frekPlaces = ValueStore().frekPlaces
        guard let frekIndex = frekPlaces.firstIndex(where: { $0.id == id }) else {
            print("❌ Couldn't find frekPlace with id: \(id)")
            fatalError()
        }
        frekPlaces[frekIndex].favorite = !frekPlaces[frekIndex].favorite
        ValueStore().frekPlaces = frekPlaces
        return frekPlaces[frekIndex].favorite
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                isFavorite = toggleFavorite()
            }
            #if os(watchOS)
                CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
            #endif
        }, label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? .red : .gray)
        })
        .buttonStyle(PlainButtonStyle())
    }
}
