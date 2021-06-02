//
//  FrekApp.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-28.
//

import SwiftUI

struct FrekApp: View {    
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
        FrekPlaceGrid()
    }
    #endif
    
    var list: some View {
        FrekPlaceList()
    }
}
