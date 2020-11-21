//
//  RefreshButton.swift
//  FrekWatch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-11-21.
//

import SwiftUI

struct RefreshButton: View {
    @State var refreshing: Bool
    let refresh: () -> Void
    
    var body: some View {
        Button(action: { withAnimation { self.refresh() } }, label: { Text(refreshing ? "🔄 Refreshing" : "🔄 Refresh") })
        .buttonStyle(PlainButtonStyle())
    }
}
