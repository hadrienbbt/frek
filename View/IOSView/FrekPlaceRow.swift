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
            if frekPlace.isOpen, DeviceMeta().idiom == .phone {
                FrekCrowd(crowd: $frekPlace.crowd)
            }
        }
    }
}

struct FrekDescription: View {
    @Binding var frekPlace: FrekPlace

    var description: String {
        if frekPlace.isOpen {
            if DeviceMeta().idiom == .phone {
                return "Ouverte"
            } else {
                return "\(frekPlace.crowd) personnes sur place"
            }
        } else {
            return "Fermée"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(frekPlace.name)
                    .font(.headline)
                ToggleFavoriteButton(frekPlace: $frekPlace)
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Max: \(frekPlace.fmi)")
                .font(.subheadline)
                .foregroundColor(.secondary)
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
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
