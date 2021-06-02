//
//  FrekPlaceDetail.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-04-11.
//

import SwiftUI

struct FrekPlaceDetail: View {
    @Binding var frekPlace: FrekPlace
        
    let imageSize: CGFloat = 200
    
    var toggleButton: some View {
        ToggleFavoriteButton(frekPlace: $frekPlace)
    }
    
    func createFrekChartRow(_ frekChart: FrekChart) -> FrekChartRow {
        let index = frekPlace.frekCharts.firstIndex(where: { frekChart.id == $0.id })!
        let viewModel = FrekChartViewModel(chart: frekPlace.frekCharts[index])
        return FrekChartRow(viewModel: viewModel)
    }
    
    var body: some View {
        ScrollView {
            MapView(coordinate: frekPlace.coordinate)
                .frame(height: 300)
            CircleImage(image: Image(frekPlace.suffix), size: imageSize)
                .offset(y: -imageSize / 2)
                .padding(.bottom, -imageSize / 2)
            VStack(alignment: .leading) {
                HStack {
                    Text(frekPlace.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    toggleButton
                        .imageScale(.large)
                }
                Text(frekPlace.isOpen ? "\(frekPlace.crowd) personnes sur place\nMax: \(frekPlace.fmi)" : "Fermée")
                    .font(.title2)
                    .foregroundColor(.secondary)
                ForEach(frekPlace.frekCharts) {
                    self.createFrekChartRow($0)
                }
            }
            .padding()
        }
        // .navigationBarItems(trailing: toggleButton)
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
