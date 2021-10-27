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
    
    var url: URL {
        return URL(string: "frek://\(id)")!
    }
        
    var description: String {
        return "\(crowd) personne à la salle \(name)."
    }
    
    static var samples = [sample1, sample2, sample3]
    
    static var sample1: FrekPlace {
        return FrekPlace(
            id: "1",
            name: "Bastille",
            suffix: "bastille-12eme",
            latitude: 0.0,
            longitude: 0.0,
            crowd: 32,
            spotsAvailable: 128,
            fmi: 160,
            state: true,
            favorite: true,
            frekCharts: []
        )
    }
    
    static var sample2: FrekPlace {
        return FrekPlace(
            id: "2",
            name: "Magenta",
            suffix: "magenta-10eme",
            latitude: 0.0,
            longitude: 0.0,
            crowd: 54,
            spotsAvailable: 86,
            fmi: 140,
            state: true,
            favorite: true,
            frekCharts: []
        )
    }
    
    static var sample3: FrekPlace {
        return FrekPlace(
            id: "3",
            name: "République",
            suffix: "republique-11eme",
            latitude: 0.0,
            longitude: 0.0,
            crowd: 12,
            spotsAvailable: 98,
            fmi: 110,
            state: true,
            favorite: true,
            frekCharts: []
        )
    }
    
    
    func toGym() -> Gym {
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
