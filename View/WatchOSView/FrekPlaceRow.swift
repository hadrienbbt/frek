//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-21.
//

import SwiftUI

struct FrekPlaceRow: View {
    @Binding var frekPlace: FrekPlace
    
    let image: AsyncImage<Text>
    
    var body: some View {
        VStack {
            HStack {
                FrekThumbnail(image: image)
                    .padding()
                Text("\(frekPlace.crowd)")
                    .font(.title)
                    
            }
            VStack(alignment: .leading, spacing: 0) {
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
            
        }
    }
}
