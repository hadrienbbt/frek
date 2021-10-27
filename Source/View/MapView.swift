import SwiftUI
import MapKit

struct MapView: View {
    @Binding var isExpanded: Bool
    @State private var region = MKCoordinateRegion()

    var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        let annotations = [AnnotatedItem(coordinate: coordinate)]
        Map(coordinateRegion: $region,
            interactionModes: isExpanded ? [.all] : [],
            annotationItems: annotations
        ) { annotation in
            MapMarker(coordinate: annotation.coordinate)
            
        }
            .onAppear { setRegion(coordinate) }
            .if(isExpanded) { map in
                map.frame(height: 750)
            }
            .if(!isExpanded) { map in
                map
                    // .onTapGesture { isExpanded.toggle() }
                    .frame(height: 300)
            }
    }

    private func setRegion(_ coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
}

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}
