import Foundation
import Intents

class IntentHandler: INExtension, SelectGymIntentHandling {
    func resolveFrekPlace(for intent: SelectGymIntent, with completion: @escaping (GymResolutionResult) -> Void) {
        if let frekPlace = intent.frekPlace {
            completion(.success(with: frekPlace))
        } else {
            let frekplaces = FrekPlaceListViewModel().sortedFrekPlaces.map { $0.toGym() }
            completion(.disambiguation(with: frekplaces))
        }
    }
        
    func provideFrekPlaceOptionsCollection(for intent: SelectGymIntent, searchTerm: String?) async throws -> INObjectCollection<Gym> {
        let viewModel = FrekPlaceListViewModel()
        await viewModel.fetchFrekPlaces()
        let gyms = viewModel.frekPlaces
            .sorted(by: { $0.name < $1.name })
            .map { $0.toGym() }
        return INObjectCollection(items: gyms)
    }
}
