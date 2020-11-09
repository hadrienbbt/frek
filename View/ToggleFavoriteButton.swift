//
//  ToggleFavoriteButton.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-22.
//

import SwiftUI

struct ToggleFavoriteButton: View {
    @Binding var isFavorite: Bool
    
    var body: some View {
        Button(action: { withAnimation { isFavorite = !isFavorite } }, label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? .red : .gray)
        })
        .buttonStyle(PlainButtonStyle())
    }
}
