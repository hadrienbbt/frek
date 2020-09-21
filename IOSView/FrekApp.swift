//
//  FrekApp.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import SwiftUI

@main
struct FrekApp: App {
    let crowdFetcher = CrowdFetcher()
    
    var body: some Scene {
        WindowGroup {
            FrekPlaceList(crowdFetcher: crowdFetcher)
        }
    }
}

struct FrekApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
