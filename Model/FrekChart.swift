//
//  FrekChart.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-05-30.
//

import Foundation
import SwiftUI
import SwiftUICharts

struct FrekChart: Identifiable, Decodable, Encodable {
    var id = UUID()
    let dataset: [Double]
    let date: Date
    let fmi: Int
    
    var isOpen: Bool { dataset.contains { $0 != 0 } }
    
}
