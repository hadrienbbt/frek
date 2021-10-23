//
//  IntentHandler.swift
//  Frek
//
//  Created by Hadrien Barbat on 23/10/2021.
//

import Foundation
import Intents

class IntentHandler: INExtension, SelectGymIntentHandling {
    func resolveFrekPlace(for intent: SelectGymIntent, with completion: @escaping (GymResolutionResult) -> Void) {
        if let frekPlace = intent.frekPlace {
            completion(.success(with: frekPlace))
        } else {
            let frekplaces = FrekPlaceListViewModel().frekPlaces.map { $0.encode() }
            completion(.disambiguation(with: frekplaces))
        }
    }
        
    func provideFrekPlaceOptionsCollection(for intent: SelectGymIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Gym>?, Error?) -> Void) {
        FrekPlaceListViewModel().fetchFrekPlaces { frekPlaces in
            let frekplaces = frekPlaces.map { $0.encode() }
            let collection = INObjectCollection(items: frekplaces)
            completion(collection, nil)
        }
    }
}
