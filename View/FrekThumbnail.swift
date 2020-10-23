//
//  FrekThumbnail.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-28.
//

import SwiftUI

struct FrekThumbnail: View {
    let image: AsyncImage<Text>
    
    var body: some View {
        image
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 10)
    }
}
