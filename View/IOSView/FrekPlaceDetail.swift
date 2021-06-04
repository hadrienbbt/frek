//
//  FrekPlaceDetail.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-04-11.
//

import SwiftUI

struct FrekPlaceDetail: View {
    @Binding var frekPlace: FrekPlace
    @State var isExpanded = false
    
    var toggleButton: some View {
        ToggleFavoriteButton(frekPlace: $frekPlace)
    }
    
    func createFrekChartRow(_ frekChart: FrekChart) -> FrekChartRow {
        let index = frekPlace.frekCharts.firstIndex(where: { frekChart.id == $0.id })!
        let viewModel = FrekChartViewModel(chart: frekPlace.frekCharts[index])
        return FrekChartRow(viewModel, index == 0)
    }
    
    private var axes: Axis.Set {
        return isExpanded ? [] : .vertical
    }
    
    let animationDuration: Double = 0.2
    
    var body: some View {
        ScrollView(axes) {
            VStack {
                MapView(isExpanded: $isExpanded, coordinate: frekPlace.coordinate)
                    .animation(.easeInOut(duration: animationDuration))
                CircleImage(isMapExpanded: $isExpanded, frekImage: Image(frekPlace.suffix))
                    .animation(.easeInOut(duration: animationDuration))
                if !isExpanded {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(frekPlace.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            /* toggleButton
                                .imageScale(.large) */
                        }
                        Text(frekPlace.isOpen ? "\(frekPlace.crowd) personnes sur place\nMax: \(frekPlace.fmi)" : "Fermée")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        ForEach(frekPlace.frekCharts) {
                            self.createFrekChartRow($0)
                        }
                    }
                    .padding()
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: animationDuration))
                }
            }
        }
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct CircleImage: View {
    @Binding var isMapExpanded: Bool
    let frekImage: Image
    
    var image: Image { isMapExpanded ? Image(systemName: "arrow.up.circle.fill") : frekImage }
    var imageSize: CGFloat { isMapExpanded ? 100 : 200 }
    
    var body: some View {
        image
            .resizable()
            .frame(width: imageSize, height: imageSize)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: isMapExpanded ? 0 : 4))
            .offset(y: -imageSize / 2)
            .padding(.bottom, -imageSize / 2)
            .if(isMapExpanded) { image in
                image
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        isMapExpanded.toggle()
                    }
            }
            .if(!isMapExpanded) { image in
                image
                    .shadow(radius: 7)
            }
    }
}

struct PreventableScrollView<Content>: View where Content: View {
    @Binding var preventScroll: Bool
    var content: () -> Content
    
    var body: some View {
        if preventScroll {
            content()
        } else {
            ScrollView(.vertical, showsIndicators: false, content: content)
                .animation(.easeInOut)
        }
    }
}
