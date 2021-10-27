//
//  ToggleFavoriteButton.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-22.
//

import SwiftUI
#if os(watchOS)
import ClockKit
#elseif os(iOS)
import WidgetKit
#endif

struct ToggleFavoriteButton: View {
    @Binding var frekPlace: FrekPlace

    func toggleFavorite() {
        withAnimation {
            frekPlace.favorite.toggle()
        }
#if os(watchOS)
            CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
#elseif os(iOS)
            WidgetCenter.shared.reloadAllTimelines()
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
