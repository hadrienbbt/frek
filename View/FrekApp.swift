//
//  FrekApp.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-28.
//

import SwiftUI

struct FrekApp: View {
    @ObservedObject
    var crowdFetcher = CrowdFetcher()
    
    @ViewBuilder
    var body: some View {
        #if os(iOS)
        if DeviceMeta().idiom != .phone {
            grid
        } else {
            list
        }
        #elseif os(watchOS)
            list
        #endif
        
    }
    
    var grid: some View {
        FrekPlaceGrid(frekPlaces: crowdFetcher.frekPlaces)
    }
    
    var list: some View {
        FrekPlaceList(
            frekPlaces: crowdFetcher.frekPlaces,
            refresh: crowdFetcher.refresh
        )
    }
}
