//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceRow: View {
    @Binding var frekPlace: FrekPlace
        
    var body: some View {
        HStack {
            FrekThumbnail(name: frekPlace.suffix)
            FrekDescription(frekPlace: $frekPlace)
            Spacer()
            if frekPlace.isOpen {
                FrekCrowd(crowd: $frekPlace.crowd)
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
                ToggleFavoriteButton(frekPlace: $frekPlace)
            }
            Text(frekPlace.isOpen ? "Ouverte" : "Fermée")
                .font(.subheadline)
            Text("Max: \(frekPlace.fmi)")
                .font(.subheadline)
        }
        .padding(.horizontal, 5)
    }
}

struct FrekCrowd: View {
    @Binding var crowd: Int
    
    var body: some View {
        VStack {
            Text(crowd.description)
                .font(.title)
            Text("Personnes\nsur place")
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
    }
}
