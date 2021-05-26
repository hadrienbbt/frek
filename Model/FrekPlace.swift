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
    var suffix: String
    
    var latitude: Double?
    var longitude: Double?

    var crowd: Int
    var spotsAvailable: Int
    var fmi: Int
    var state: Bool
    var favorite: Bool = false
    
    init (_ id: String, _ name: String, _ suffix: String, _ crowd: Int, _ spotsAvailable: Int, _ fmi: Int, _ state: Bool, _ latitude: Double, _ longitude: Double) {
        self.id = id
        self.name = name
        self.suffix = suffix
        self.crowd = crowd
        self.spotsAvailable = spotsAvailable
        self.fmi = fmi
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ id: String, _ name: String, _ gymHTML: String, _ frekHTML: String) {
        self.id = id
        self.name = name
        self.suffix = FrekWebsiteSuffix[name] ?? "placeholder"
        self.crowd = CrowdParser.findCrowd(from: frekHTML)
        self.spotsAvailable = CrowdParser.findSpotsAvailable(from: frekHTML)
        self.fmi = crowd + spotsAvailable
        self.state = CrowdParser.findState(for: frekHTML)
        self.latitude = CrowdParser.findLatitude(for: gymHTML)
        self.longitude = CrowdParser.findLongitude(for: gymHTML)

        // CrowdParser.findChart(for: 7, in: frekHTML)
    }
    
    static func decode(_ dict: Dict) -> FrekPlace? {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let suffix = dict["suffix"] as? String,
            let crowd = dict["crowd"] as? Int,
            let spotsAvailable = dict["spotsAvailable"] as? Int,
            let fmi = dict["fmi"] as? Int,
            let state = dict["state"] as? Bool,
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double
            else { return nil }
        return FrekPlace(id, name, suffix, crowd, spotsAvailable, fmi, state, latitude, longitude)
    }
    
    var description: String {
        return "\(crowd) personne à la salle \(name)."
    }
    
    
}
