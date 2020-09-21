//
//  FrekPlace.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation

class FrekPlace: Identifiable, Decodable, Encodable {
    let id: String
    let name: String
    let image: URL
    
    var crowd: Int
    var spotsAvailable: Int
    var fmi: Int
    var state: Bool
    
    init(_ id: String, _ name: String, _ gymHTML: String, _ frekHTML: String) {
        self.id = id
        self.name = name
        self.image = CrowdParser.findImage(from: gymHTML)
        self.crowd = CrowdParser.findCrowd(from: frekHTML)
        self.spotsAvailable = CrowdParser.findSpotsAvailable(from: frekHTML)
        self.fmi = crowd + spotsAvailable
        self.state = CrowdParser.findState(for: frekHTML)
        // CrowdParser.findChart(for: 7, in: frekHTML)
    }
    
    var description: String {
        return "\(crowd) personne à la salle \(name)."
    }
    
    
}
