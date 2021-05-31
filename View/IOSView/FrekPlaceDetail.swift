//
//  FrekPlaceDetail.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-04-11.
//

import SwiftUI

struct FrekPlaceDetail: View {
    @Binding var frekPlace: FrekPlace
    
    let formatter = FrekFormatter()
    let imageSize: CGFloat = 200
    
    var toggleButton: some View {
        ToggleFavoriteButton(id: frekPlace.id, isFavorite: $frekPlace.favorite)
    }
    
    var body: some View {
        ScrollView {
            MapView(coordinate: frekPlace.coordinate)
                .frame(height: 300)
            CircleImage(image: Image(frekPlace.suffix), size: imageSize)
                .offset(y: -imageSize / 2)
                .padding(.bottom, -imageSize / 2)
            VStack(alignment: .leading) {
                Text(frekPlace.name)
                    .font(.title)
                    .foregroundColor(.primary)
                HStack {
                    Text("\(frekPlace.crowd) personnes sur place")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    toggleButton
                }
                
                ForEach(frekPlace.frekCharts) {
                    Divider()
                    Text(formatter.string(from: $0.date))
                        .font(.title2)
                    Text("Description")
                    $0.getLineChart()
                }
                
            }
            .padding()
        }
        // .navigationBarTitle(frekPlace.name)
        // .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: toggleButton)
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct CircleImage: View {
    var image: Image
    var size: CGFloat
    
    var body: some View {
        image
            .resizable()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 7)
    }
}
