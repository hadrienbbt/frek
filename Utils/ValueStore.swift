//
//  ValueStore.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-22.
//

import Foundation

class ValueStore {
    
    var frekPlaces: [FrekPlace] {
        get {
            if let data = read("frekPlaces") as? Data,
                let frekPlaces = try? JSONDecoder().decode([FrekPlace].self, from: data) {
                return frekPlaces
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                write("frekPlaces", data)
            }
        }
    }
    
    private func read(_ key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    private func write(_ key: String, _ newValue: Any?) {
        UserDefaults.standard.set(newValue, forKey: key)
    }
    
}
