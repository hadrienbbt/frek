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
        ToggleFavoriteButton(id: frekPlace.id, isFavorite: $frekPlace.favorite)
    }
    
    func createFrekChartRow(_ frekChart: FrekChart) -> FrekChartRow {
        let index = frekPlace.frekCharts.firstIndex(where: { frekChart.id == $0.id })!
        return FrekChartRow(frekChart: $frekPlace.frekCharts[index])
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
                Text("\(frekPlace.crowd) personnes sur place")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ForEach(frekPlace.frekCharts) {
                    self.createFrekChartRow($0)
                        .animation(.easeInOut)
                }
                
            }
            .padding()
        }
        .navigationBarItems(trailing: toggleButton)
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct FrekChartRow: View {
    @Binding var frekChart: FrekChart
    @State private var showDetail = false
    
    let formatter = FrekFormatter()
    
    var body: some View {
        Divider()
        VStack {
            HStack {
                frekChart.getLineChart()
                    .frame(width: 50, height: 30)
                VStack(alignment: .leading) {
                    Text(formatter.string(from: frekChart.date))
                        .font(.headline)
                    Text("Description")
                }
                .padding()
                Spacer()
                Button(action: {
                    self.showDetail.toggle()
                }) {
                    Image(systemName: "chevron.right.circle")
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetail ? 90 : 0))
                        .padding()
                        .animation(.easeInOut)
                }
            }
            if showDetail {
                FrekChartDetail(frekChart: $frekChart)
            }
        }
    }
}

struct FrekChartDetail: View {
    @Binding var frekChart: FrekChart
    
    var body: some View {
        frekChart.getLineChart()
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
