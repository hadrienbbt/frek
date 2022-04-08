import Foundation
import Combine

protocol FrekplaceProvider {
    func getFrekplaces() async -> [FrekPlace]
}

extension FrekplaceProvider {
    func processFavorites(_ frekplaces: [FrekPlace]) -> [FrekPlace] {
        let store = ValueStore().frekPlaces
        return frekplaces.map {
            var frekplace = $0
            frekplace.favorite = store.first { $0.id == frekplace.id }?.favorite ?? false
            return frekplace
        }
    }
}

class FrekPlaceListViewModel: ObservableObject {
    
    var dataProvider: FrekplaceProvider = WebFetcher()
    
    @Published var frekPlaces = ValueStore().frekPlaces {
        didSet {
            ValueStore().frekPlaces = frekPlaces
        }
    }
    @Published var loading = true
    
    var sortedFrekPlaces: [FrekPlace] {
        frekPlaces
            .sorted(by: { $0.name < $1.name })
    }
    
    var favorites: [FrekPlace] {
        sortedFrekPlaces
            .filter { $0.favorite }
    }
    
    func fetchFrekPlaces(_ callback: (() -> Void)? = nil) {
        Task {
            let frekplaces = await dataProvider.getFrekplaces()
            DispatchQueue.main.async {
                self.frekPlaces = frekplaces
                self.loading = false
                callback?()
            }
        }
    }
}
