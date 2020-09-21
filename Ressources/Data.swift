//
//  Data.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import UIKit
import SwiftUI
import CoreLocation

// let frekPlaceData: [FrekPlace] = load("frekPlaces.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func decode<T: Decodable>(json: [String: Any]) -> T? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    } catch {
        print("Couldn't parse \(json) as \(T.self):\n\(error)")
        return nil
        
    }
}
