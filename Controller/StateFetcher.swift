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
    
    @Published var loading = false
        
    init() {
        frekPlaces = ValueStore().frekPlaces
        loadData()
    }
    
    func loadData() {
        loading = true
        fetchBackend {
            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }
    
    func updateData() {
        #if os(watchOS)
        ComplicationController.reloadAllComplicationsData()
        #endif
    }
    
    func fetchBackend(_ completion: @escaping () -> Void) {
        loading = true
        HTTPHelper.httpRequest(endpoint: "https://fedutia.fr:8003", method: .get, params: nil) { result in
            switch result {
            case .success(let dictFrekPlaces):
                self.onFrekPlacesFetched(dictFrekPlaces) {
                    print("✅ \(self.frekPlaces.count) FrekPlaces created!")
                }
            case .failure(let err):
                print("❌ Error fetching backend: \(err)")
            }
            completion()
        }
    }
    
    func onFrekPlacesFetched(_ frekPlaceDicts: [Dict], _ completion: @escaping () -> Void) {
        let taskGroup = DispatchGroup()
        frekPlaceDicts.forEach { frekPlaceDict in
            taskGroup.enter()
            processFrekPlaceDict(frekPlaceDict) { taskGroup.leave() }
        }
        taskGroup.notify(queue: .main) {
            if self.frekPlaces.count != frekPlaceDicts.count {
                self.filterRemovedFrekPlaces(frekPlaceDicts)
            }
            completion()
        }
    }
    
    func filterRemovedFrekPlaces(_ frekPlaceDicts: [Dict]) {
        self.frekPlaces = self.frekPlaces.filter { storedFrekPlace in
            return frekPlaceDicts.contains { dict in
                guard let frekPlace = FrekPlace.decode(dict) else { return false }
                return storedFrekPlace.id == frekPlace.id
            }
        }
    }
    
    func processFrekPlaceDict(_ frekPlaceDict: Dict, _ completion: @escaping () -> Void) {
        guard let frekPlace = FrekPlace.decode(frekPlaceDict) else { return }
        DispatchQueue.main.async {
            if let index = self.frekPlaces.firstIndex(where: { $0.id == frekPlace.id }) {
                self.updateFrekPlace(at: index, frekPlace)
            } else {
                self.frekPlaces.append(frekPlace)
            }
            completion()
        }
    }
    
    func updateFrekPlace(at index: Int, _ frekPlace: FrekPlace) {
        frekPlaces[index].crowd = frekPlace.crowd
        frekPlaces[index].spotsAvailable = frekPlace.spotsAvailable
        frekPlaces[index].fmi = frekPlace.fmi
        frekPlaces[index].state = frekPlace.state
    }
}
