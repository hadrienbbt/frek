//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-21.
//

import SwiftUI

struct FrekPlaceRow: View {
    @Binding var frekPlace: FrekPlace
        
    var body: some View {
        VStack {
            HStack {
                FrekThumbnail(name: frekPlace.suffix)
                    .padding()
                Text("\(frekPlace.crowd)")
                    .font(.title)
                    
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(frekPlace.name)
                        .font(.headline)
                    ToggleFavoriteButton(frekPlace: $frekPlace)
                }
                /* Text(frekPlace.state ? "Ouvert" : "Fermé")
                    .font(.subheadline) */
                Text("Max: \(frekPlace.fmi)")
                    .font(.subheadline)
            }
            
        }
    }
}
