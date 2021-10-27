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
