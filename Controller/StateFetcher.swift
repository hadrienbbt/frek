//
//  StateFetcher.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation

#if os(watchOS)
import ClockKit
#endif

class StateFetcher: ObservableObject {
        
    @Published var frekPlaces: [FrekPlace] {
        didSet {
            ValueStore().frekPlaces = frekPlaces
        }
    }
    
    @Published var refreshing = false
        
    init() {
        frekPlaces = ValueStore().frekPlaces
        fetchBackend()
    }
    
    func refresh() {
        fetchBackend()
    }
    
    func updateData() {
        #if os(watchOS)
        ComplicationController.reloadAllComplicationsData()
        #endif
    }
    
    func fetchBackend() {
        refreshing = true
        HTTPHelper.httpRequest(endpoint: "https://fedutia.fr:8003", method: .get, params: nil) { result in
            switch result {
            case .success(let dictFrekPlaces):
                self.onFrekPlacesFetched(dictFrekPlaces)
                print("✅ \(self.frekPlaces.count) FrekPlacecs created!")
            case .failure(let err):
                print("❌ Error fetching backend: \(err)")
            }
        }
    }
    
    func onFrekPlacesFetched(_ frekPlaces: [Dict]) {
        frekPlaces.forEach { frekPlaceDict in
            if let frekPlace = FrekPlace.decode(frekPlaceDict) {
                DispatchQueue.main.async {
                    if let index = self.frekPlaces.firstIndex(where: { $0.id == frekPlace.id }) {
                        self.updateFrekPlace(at: index, frekPlace)
                    } else {
                        self.frekPlaces.append(frekPlace)
                    }
                }
            }
        }
    }
    
    func updateFrekPlace(at index: Int, _ frekPlace: FrekPlace) {
        frekPlaces[index].crowd = frekPlace.crowd
        frekPlaces[index].spotsAvailable = frekPlace.spotsAvailable
        frekPlaces[index].fmi = frekPlace.fmi
        frekPlaces[index].state = frekPlace.state
    }
}
