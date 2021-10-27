//
//  FrekChart.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-05-30.
//

import Foundation
import SwiftUI

struct FrekChart: /*NSObject, NSSecureCoding,*/ Identifiable, Decodable, Encodable {
    static var supportsSecureCoding = true

    var id = UUID()
    let dataset: [Double]
    let date: Date
    let fmi: Int
    
    var isOpen: Bool { dataset.contains { $0 != 0 } }
    var fmiDataset: [Double] { dataset.map { _ in Double(fmi) }}
    /*
    init(dataset: [Double], date: Date, fmi: Int) {
        self.dataset = dataset
        self.date = date
        self.fmi = fmi
    }
    
    required convenience init?(coder: NSCoder) {
        guard let dataset = coder.decodeObject(forKey: "dataset") as? [Double],
              let date = coder.decodeObject(forKey: "date") as? Date,
              let fmi = coder.decodeObject(forKey: "fmi") as? Int else {
                  return nil
              }
        self.init(dataset: dataset, date: date, fmi: fmi)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(dataset, forKey: "dataset")
        coder.encode(date, forKey: "date")
        coder.encode(fmi, forKey: "fmi")
    }
     */
}
