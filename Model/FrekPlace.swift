//
//  FrekPlace.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation

struct FrekPlace: Identifiable, Decodable, Encodable {
    let id: String
    let name: String
    let image: URL
    
    var latitude: Double?
    var longitude: Double?

    var crowd: Int
    var spotsAvailable: Int
    var fmi: Int
    var state: Bool
    var favorite: Bool = false
    
    init(_ id: String, _ name: String, _ gymHTML: String, _ frekHTML: String) {
        self.id = id
        self.name = name
        self.image = CrowdParser.findImage(from: gymHTML)
        self.crowd = CrowdParser.findCrowd(from: frekHTML)
        self.spotsAvailable = CrowdParser.findSpotsAvailable(from: frekHTML)
        self.fmi = crowd + spotsAvailable
        self.state = CrowdParser.findState(for: frekHTML)
        self.latitude = CrowdParser.findLatitude(for: gymHTML)
        self.longitude = CrowdParser.findLongitude(for: gymHTML)

        // CrowdParser.findChart(for: 7, in: frekHTML)
    }
    
    var description: String {
        return "\(crowd) personne à la salle \(name)."
    }
    
    
}
