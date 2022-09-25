import WidgetKit
import SwiftUI

@main
struct FrekBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
#if os(watchOS)
        SimpleFrekPlaceWidget()
#else
        SimpleFrekPlaceWidget()
        FavoriteFrekPlaceWidget()
#endif
    }
}
