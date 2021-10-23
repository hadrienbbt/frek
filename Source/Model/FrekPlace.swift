//
//  FrekPlace.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation
import MapKit
import Intents

struct FrekPlace: Identifiable, Decodable, Encodable {
    let id: String
    let name: String
    var suffix: String
    
    var latitude: Double
    var longitude: Double

    var crowd: Int
    var spotsAvailable: Int
    var fmi: Int
    var state: Bool
    var favorite: Bool = false
    
    var frekCharts: [FrekChart]
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var isOpen: Bool {
        return state // && (frekCharts.first?.isOpen ?? false)
    }
        
    var description: String {
        return "\(crowd) personne à la salle \(name)."
    }
    
    func encode() -> Gym {
        let gym = Gym(
            identifier: id,
            display: name,
            subtitle: nil,
            image: INImage(named: suffix)
        )
        gym.suffix = suffix
        gym.fmi = fmi as NSNumber
        gym.crowd = crowd as NSNumber
        return gym
    }
}
