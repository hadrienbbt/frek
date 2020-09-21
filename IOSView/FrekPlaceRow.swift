//
//  FrekPlaceRow.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceRow: View {
    @ObservedObject var crowdFetcher: CrowdFetcher
    @Binding var frekPlace: FrekPlace
    var cache: ImageCache
    
    var body: some View {
        HStack {
            AsyncImage(url: frekPlace.image, placeholder: Text("⏳"), cache: self.cache) { $0.resizable() }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
                .padding()
            VStack(alignment: .leading) {
                Text(frekPlace.name)
                    .font(.title)
                Text(frekPlace.state ? "Ouvert" : "Fermé")
                    .font(.subheadline)
                // Button("Log html", action: { print(crowdFetcher.htmlDataSource[frekPlace.id] ?? "No HTML") })
            }
            Spacer()
            Text("\(frekPlace.crowd)/\(frekPlace.fmi)")
                .padding()
        }
        
    }
}

struct FrekPlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
