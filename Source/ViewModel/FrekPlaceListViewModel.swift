//
//  FrekPlacesViewModel.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-06-02.
//

import Foundation
import Combine
import ClockKit

class FrekPlaceListViewModel: ObservableObject {
    
    @Published var frekPlaces = ValueStore().frekPlaces {
        didSet {
            ValueStore().frekPlaces = frekPlaces
        }
    }
    @Published var loading = false
    
    private var cancellable: AnyCancellable?
    private var backgroundQueue = DispatchQueue(label: "FrekPlaceListViewModel")
    
    let url: URL! = URL(string: "https://fedutia.fr/frek")
    
    var sortedFrekPlaces: [FrekPlace] {
        frekPlaces
            .sorted(by: { $0.name < $1.name })
    }
    
    var favorites: [FrekPlace] {
        sortedFrekPlaces
            .filter { $0.favorite }
    }
    
    func fetchFrekPlaces(_ callback: (() -> Void)? = nil)  {
        loading = true
        
        let receiveCompletion: (Subscribers.Completion<Error>) -> Void = {
            self.receiveCompletion($0)
            callback?()
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .timeout(10, scheduler: backgroundQueue)
            .retry(3)
            .map { $0.data }
            .decode(type: [FrekPlace].self, decoder: FrekDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: receiveCompletion,
                receiveValue: self.receiveFrekPlaces
            )
    }
    
    func receiveFrekPlaces(_ frekPlaces: [FrekPlace]) {
        self.frekPlaces = frekPlaces.map {
            var frekPlace = $0
            frekPlace.favorite = self.frekPlaces.first { $0.id == frekPlace.id }?.favorite ?? false
            return frekPlace
        }
    }
    
    func receiveCompletion(_ completion: Subscribers.Completion<Error>) -> Void {
        switch completion {
        case .failure(let error): print("❌ Error fetching backend: \(error)")
        case .finished:
            #if os(watchOS)
            // ComplicationController.reloadAllComplicationsData()
            #endif
            print("✅ Fetching finished with \(self.frekPlaces.count) FrekPlaces created!")
        }
        self.loading = false
    }
}
