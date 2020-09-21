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
    @State var refreshed = false
    
    func refresh() {
        self.crowdFetcher.refresh()
        refreshed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            refreshed = false
        }
    }
    
    var body: some View {
        NavigationView {
            List(crowdFetcher.frekPlaces.sorted(by: { $0.name < $1.name })) { frekPlace in
                FrekPlaceRow(
                    frekPlace: frekPlace,
                    image: AsyncImage(url: frekPlace.image, placeholder: Text("⏳"), cache: self.cache) { $0.resizable() }
                )
            }
            .navigationBarTitle(Text("Frek Places"))
            .navigationBarItems(trailing: Button(refreshed ? "✅ Refreshed" : "🔄 Refresh") { self.refresh() }).disabled(refreshed)
        }
    }
}

struct FrekPlaceList_Previews: PreviewProvider {
    static var previews: some View {
        FrekPlaceList(crowdFetcher: CrowdFetcher())
    }
}
