//
//  FrekPlaceDetail.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-04-11.
//

import SwiftUI
import MapKit

struct FrekPlaceDetail: View {
    @Binding var frekPlace: FrekPlace
    

    var body: some View {
        let region = Binding<MKCoordinateRegion>(
            get: {
                print(self.frekPlace.latitude)

                return
                    MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.frekPlace.latitude!, longitude: self.frekPlace.longitude!), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            },
            set: { value in
                self.frekPlace.latitude = value.center.latitude
                self.frekPlace.longitude = value.center.longitude
            }
        )
        
        Map(coordinateRegion: region, interactionModes: [.zoom])
            .frame(width: 400, height: 300)
    }
}
