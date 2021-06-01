//
//  extenstions.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-06-01.
//

import Foundation
import SwiftUI

extension View {
   @ViewBuilder
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}

