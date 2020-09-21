//
//  ContentView.swift
//  FrekWatch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var crowdFetcher: CrowdFetcher
    
    var body: some View {
        Text("\(crowdFetcher.crowd)/\(crowdFetcher.fmi)")
            .padding()
        Button("🔄", action: { crowdFetcher.refresh() })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(crowdFetcher: CrowdFetcher())
    }
}
