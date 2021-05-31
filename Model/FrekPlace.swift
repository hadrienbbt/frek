//
//  FrekPlace.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation
import MapKit

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
    
    init (_ id: String, _ name: String, _ suffix: String, _ crowd: Int, _ spotsAvailable: Int, _ fmi: Int, _ state: Bool, _ latitude: Double, _ longitude: Double, _ charts: [FrekChart]) {
        self.id = id
        self.name = name
        self.suffix = suffix
        self.crowd = crowd
        self.spotsAvailable = spotsAvailable
        self.fmi = fmi
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.frekCharts = charts
    }
    
    static func decode(_ dict: Dict) -> FrekPlace? {
        guard let id = dict["frekId"] as? String,
            let name = dict["name"] as? String,
            let suffix = dict["suffix"] as? String,
            let crowd = dict["crowd"] as? Int,
            let spotsAvailable = dict["spotsAvailable"] as? Int,
            let fmi = dict["fmi"] as? Int,
            let state = dict["state"] as? Bool,
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double,
            let datasets = dict["datasets"] as? [Dict],
            let charts = datasets.map ({ FrekChart.decode($0, fmi) }) as? [FrekChart]
            else {
                print("❌ Error parsing frekplace dictionnary")
                return nil
        }
        return FrekPlace(id, name, suffix, crowd, spotsAvailable, fmi, state, latitude, longitude, charts)
    }
    
    var description: String {
        return "\(crowd) personne à la salle \(name)."
    }
    
    
}
