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
    
    let url: URL! = URL(string: "https://fedutia.fr/frek")
    
    var sortedFrekPlaces: [FrekPlace] {
        frekPlaces
            .sorted(by: { $0.name < $1.name })
    }
    
    var favorites: [FrekPlace] {
        sortedFrekPlaces
            .filter { $0.favorite }
    }
    
    func fetchFrekPlaces(_ callback: (([FrekPlace]) -> Void)? = nil)  {
        loading = true
        let reveiveValue: ([FrekPlace]) -> Void = {
            self.receiveFrekPlaces($0)
            callback?($0)
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [FrekPlace].self, decoder: FrekDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: self.receiveCompletion,
                receiveValue: reveiveValue
            )
    }
    
    func receiveFrekPlaces(_ frekPlaces: [FrekPlace]) {
        self.frekPlaces = frekPlaces.map {
            var frekPlace = $0
            frekPlace.favorite = self.frekPlaces.first { $0.id == frekPlace.id }?.favorite ?? false
            return frekPlace
        }
    }
    
    func receiveCompletion(completion: Subscribers.Completion<Error>) -> Void {
        switch completion {
        case .failure(let error): print("❌ Error fetching backend: \(error)")
        case .finished:
            #if os(watchOS)
            // ComplicationController.reloadAllComplicationsData()
            #endif
            self.loading = false
            print("✅ Fetching finished with \(self.frekPlaces.count) FrekPlaces created!")
        }
    }
}
