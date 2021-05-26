//
//  FrekApp.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-28.
//

import SwiftUI

struct FrekApp: View {
    @ObservedObject
    var stateFetcher = StateFetcher()
    
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
    
    #if os(iOS)
    var grid: some View {
        FrekPlaceGrid(frekPlaces: stateFetcher.frekPlaces)
    }
    #endif
    
    var list: some View {
        FrekPlaceList(
            frekPlaces: $stateFetcher.frekPlaces,
            loading: $stateFetcher.loading
        )
    }
}
