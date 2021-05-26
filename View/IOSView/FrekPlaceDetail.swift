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
        let image = Image(frekPlace.suffix)
        VStack {
            MapView(coordinate: frekPlace.coordinate)
                .ignoresSafeArea(edges: .top)
                .frame(height: 150)
            CircleImage(image: image)
                .offset(y: -100)
                .padding(.bottom, -100)
            
            VStack(alignment: .leading) {
                Text(frekPlace.name)
                    .font(.title)
                    .foregroundColor(.primary)
                HStack {
                    Text("\(frekPlace.crowd) personnes sur place")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    ToggleFavoriteButton(id: frekPlace.id, isFavorite: $frekPlace.favorite)
                }
                Divider()
                Text("Title")
                    .font(.title2)
                Text("Description")
            }
            .padding()
            Spacer()
        }
    }
}

struct MapView: View {
    var coordinate: CLLocationCoordinate2D
    @State private var region = MKCoordinateRegion()

    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear {
                setRegion(coordinate)
            }
    }

    private func setRegion(_ coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
    }
}

struct CircleImage: View {
    var image: Image

    var body: some View {
        image
            .resizable()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 7)
    }
}
