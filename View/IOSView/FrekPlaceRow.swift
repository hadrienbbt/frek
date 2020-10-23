//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceRow: View {
    @Binding var frekPlace: FrekPlace
    
    let image: AsyncImage<Text>
    
    var body: some View {
        HStack {
            FrekThumbnail(image: image)
                .padding([.top, .bottom], 10)
            FrekDescription(frekPlace: $frekPlace)
            Spacer()
            VStack {
                Text("\(frekPlace.crowd)")
                    .font(.title)
                Text("Personnes\nsur place")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct FrekDescription: View {
    @Binding var frekPlace: FrekPlace

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(frekPlace.name)
                    .font(.headline)
                ToggleFavoriteButton(isFavorite: $frekPlace.favorite)
            }
            /* Text(frekPlace.state ? "Ouvert" : "Fermé")
                .font(.subheadline) */
            Text("FMI: \(frekPlace.fmi)")
                .font(.subheadline)
        }
        .padding()
    }
}
