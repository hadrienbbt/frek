//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI
import MapKit

struct FrekPlaceRow: View {
    @Binding var frekPlace: FrekPlace
        
    var body: some View {
        let frekPlaceDetail = FrekPlaceDetail(frekPlace: $frekPlace)
        NavigationLink(destination: frekPlaceDetail) {
            HStack {
                FrekThumbnail(name: frekPlace.suffix)
                    .padding(.vertical)
                FrekDescription(frekPlace: $frekPlace)
                Spacer()
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
                ToggleFavoriteButton(id: frekPlace.id, isFavorite: $frekPlace.favorite)
            }
            Text(frekPlace.state ? "Ouvert" : "Fermé")
                .font(.subheadline)
            Text("FMI: \(frekPlace.fmi)")
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
