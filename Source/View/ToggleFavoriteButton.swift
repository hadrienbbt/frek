//
//  ToggleFavoriteButton.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-22.
//

import SwiftUI
import ClockKit

struct ToggleFavoriteButton: View {
    @Binding var frekPlace: FrekPlace

    func toggleFavorite() {
        withAnimation {
            frekPlace.favorite.toggle()
        }
        #if os(watchOS)
            CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
        #endif
    }
    
    var body: some View {
        Button(action: toggleFavorite, label: {
            Image(systemName: frekPlace.favorite ? "heart.fill" : "heart")
                .foregroundColor(frekPlace.favorite ? .red : .gray)
        })
        .buttonStyle(PlainButtonStyle())
    }
}
