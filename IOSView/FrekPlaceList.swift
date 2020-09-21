//
//  FrekPlaceList.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct FrekPlaceList: View {
    @ObservedObject var crowdFetcher: CrowdFetcher
    @Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        NavigationView {
            List {
                ForEach(crowdFetcher.frekPlaces.indices, id: \.description) { i in
                    HStack {
                        AsyncImage(url: self.crowdFetcher.frekPlaces[i].image, placeholder: Text("⏳"), cache: self.cache) { $0.resizable() }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(self.crowdFetcher.frekPlaces[i].name)
                                .font(.title)
                            Text(self.crowdFetcher.frekPlaces[i].state ? "Ouvert" : "Fermé")
                                .font(.subheadline)
                        }
                        Spacer()
                        Text("\(self.crowdFetcher.frekPlaces[i].crowd)/\(self.crowdFetcher.frekPlaces[i].fmi)")
                            .padding()
                    }
                }
            }
            .navigationBarTitle(Text("Frek Places"))
            .navigationBarItems(trailing:
                Button("🔄 Refresh") { self.crowdFetcher.refresh() }
            )
        }
    }
}

struct FrekPlaceList_Previews: PreviewProvider {
    static var previews: some View {
        FrekPlaceList(crowdFetcher: CrowdFetcher())
    }
}
