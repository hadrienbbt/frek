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
    
    @discardableResult
    func fetchFrekPlaces() async -> Result<[FrekPlace], FetchError> {
        let result = await dataProvider.getFrekplaces()
        switch result {
        case .success(let frakplaces):
            onFrekplaceFetched(frakplaces)
            return .success(self.frekPlaces)
        case .failure(let error):
            onError(error)
            return .failure(error)
        }
    }
    
    private func onFrekplaceFetched(_ frekplaces: [FrekPlace]) {
        DispatchQueue.main.async {
            self.frekPlaces = frekplaces.filter { $0.crowd < 2000 }
            self.loading = false
        }
    }
    
    func onError(_ error: FetchError) {
        DispatchQueue.main.async {
            self.error = error
            self.frekPlaces = []
        }
    }
}

struct FetchError: Error {
    let message: String
    let log: String
    
    init(message: String, log: String? = nil) {
        self.message = message
        self.log = log ?? message
        print(message)
    }
}
