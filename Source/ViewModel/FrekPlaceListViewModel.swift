import Foundation

protocol FrekplaceProvider {
    func getFrekplaces() async -> Result<[FrekPlace], FetchError>
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
    
    var dataProvider: FrekplaceProvider = LocalStore()
    
    @Published var frekPlaces = ValueStore().frekPlaces {
        didSet {
            ValueStore().frekPlaces = frekPlaces
        }
    }
    @Published var error: FetchError?
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
            let result = await dataProvider.getFrekplaces()
            switch result {
            case .success(let frakplaces): onFrekplaceFetched(frakplaces, callback)
            case .failure(let error): onError(error)
            }
            
        }
    }
    
    func onFrekplaceFetched(_ frekplaces: [FrekPlace], _ callback: (() -> Void)?) {
        DispatchQueue.main.async {
            self.frekPlaces = frekplaces.filter { $0.crowd < 2000 }
            self.loading = false
            callback?()
        }
    }
    
    func onError(_ error: FetchError) {
        self.error = error
        self.frekPlaces = []
    }
}

struct FetchError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
        print(message)
    }
}
