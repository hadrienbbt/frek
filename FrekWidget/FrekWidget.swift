//
//  FrekWidget.swift
//  FrekWidget
//
//  Created by Hadrien Barbat on 23/10/2021.
//

import WidgetKit
import SwiftUI

@main
struct FrekBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        SimpleFrekPlaceWidget()
        FavoriteFrekPlaceWidget()
    }
}
