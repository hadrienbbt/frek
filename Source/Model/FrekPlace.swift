//
//  FrekPlace.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation
import MapKit
import Intents

struct FrekPlace: /*NSObject, NSSecureCoding,*/ Identifiable, Decodable, Encodable {
    static var supportsSecureCoding = true
    
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
    /*
    init(id: String, name: String, suffix: String, latitude: Double, longitude: Double, crowd: Int, spotsAvailable: Int, fmi: Int, state: Bool, favorite: Bool, frekCharts: [FrekChart]) {
        self.id = id
        self.name = name
        self.suffix = suffix
        self.latitude = latitude
        self.longitude = longitude
        self.crowd = crowd
        self.spotsAvailable = spotsAvailable
        self.fmi = fmi
        self.state = state
        self.favorite = favorite
        self.frekCharts = frekCharts
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(suffix, forKey: "suffix")
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
        coder.encode(crowd, forKey: "crowd")
        coder.encode(spotsAvailable, forKey: "spotsAvailable")
        coder.encode(fmi, forKey: "fmi")
        coder.encode(state, forKey: "state")
        coder.encode(favorite, forKey: "favorite")
        coder.encode(frekCharts, forKey: "frekCharts")
    }
    
    required convenience init?(coder: NSCoder) {
        guard let id = coder.decodeObject(forKey: "id") as? String,
            let name = coder.decodeObject(forKey: "name") as? String,
            let suffix = coder.decodeObject(forKey: "suffix") as? String,
            let latitude = coder.decodeObject(forKey: "latitude") as? Double,
            let longitude = coder.decodeObject(forKey: "longitude") as? Double,
            let crowd = coder.decodeObject(forKey: "crowd") as? Int,
            let spotsAvailable = coder.decodeObject(forKey: "spotsAvailable") as? Int,
            let fmi = coder.decodeObject(forKey: "fmi") as? Int,
            let state = coder.decodeObject(forKey: "state") as? Bool,
            let favorite = coder.decodeObject(forKey: "favorite") as? Bool,
            let frekCharts = coder.decodeObject(forKey: "frekCharts") as? [FrekChart] else {
                return nil
            }
        self.init(id: id,
                  name: name,
                  suffix: suffix,
                  latitude: latitude,
                  longitude: longitude,
                  crowd: crowd,
                  spotsAvailable: spotsAvailable,
                  fmi: fmi,
                  state: state,
                  favorite: favorite,
                  frekCharts: frekCharts)
    }
    
    func encode() -> [String: Any] {
        var encoded = [String: Any]()
        encoded["id"] = id
        encoded["name"] = name
        encoded["suffix"] = suffix
        encoded["latitude"] = latitude
        encoded["longitude"] = longitude
        encoded["crowd"] = crowd
        encoded["spotsAvailable"] = spotsAvailable
        encoded["fmi"] = fmi
        encoded["state"] = state
        encoded["favorite"] = favorite
        encoded["frekCharts"] = frekCharts
        return encoded
    }
    
    static func decode(_ encoded: [String: Any]) -> FrekPlace {
        guard let id = encoded["id"] as? String,
            let name = encoded["name"] as? String,
            let suffix = encoded["suffix"] as? String,
            let latitude = encoded["latitude"] as? Double,
            let longitude = encoded["longitude"] as? Double,
            let crowd = encoded["crowd"] as? Int,
            let spotsAvailable = encoded["spotsAvailable"] as? Int,
            let fmi = encoded["fmi"] as? Int,
            let state = encoded["state"] as? Bool,
            let favorite = encoded["favorite"] as? Bool,
            let frekCharts = encoded["frekCharts"] as? [FrekChart] else {
                  return FrekPlace.samples.randomElement()!
            }
        return FrekPlace(
            id: id,
            name: name,
            suffix: suffix,
            latitude: latitude,
            longitude: longitude,
            crowd: crowd,
            spotsAvailable: spotsAvailable,
            fmi: fmi,
            state: state,
            favorite: favorite,
            frekCharts: frekCharts
        )
    }
    */
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
