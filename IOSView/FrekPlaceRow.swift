//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceRow: View {
    var frekPlace: FrekPlace
    let image: AsyncImage<Text>
    
    var body: some View {
        HStack {
            image
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)
                .padding()
            VStack(alignment: .leading) {
                Text(frekPlace.name)
                    .font(.headline)
                Text(frekPlace.state ? "Ouvert" : "Fermé")
                    .font(.subheadline)
                Text("FMI: \(frekPlace.fmi)")
                    .font(.subheadline)
            }
            Spacer()
            Text("\(frekPlace.crowd)")
                .font(.title)
                .padding()
        }
        
    }
}

struct FrekPlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
