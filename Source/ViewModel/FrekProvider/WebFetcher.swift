import Foundation
#if os(watchOS)
import ClockKit
#endif

class WebFetcher: FrekplaceProvider {
    private let url: URL! = URL(string: "https://frek.fedutia.fr/gym")
    
    func getFrekplaces() async -> Result<[FrekPlace], FetchError> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let urlResponse = response as? HTTPURLResponse else { fatalError() }
            guard urlResponse.statusCode == 200 else {
                let errorCode = HTTPURLResponse.localizedString(forStatusCode: urlResponse.statusCode)
                let fetchError = FetchError(message: "Erreur \(errorCode)", log: "❌ Error fetching backend\n\(urlResponse.statusCode): \(errorCode)")
                return .failure(fetchError)
            }
            let frekplaces = try FrekDecoder().decode([FrekPlace].self, from: data)
            #if os(watchOS)
                await ComplicationController.reloadAllComplicationsData()
            #endif
            print("✅ Fetching finished with \(frekplaces.count) FrekPlaces created!")
            return .success(processFavorites(frekplaces)) 
        } catch {
            let fetchError = FetchError(message: error.localizedDescription, log: "❌ Error fetching backend: \(error)")
            return .failure(fetchError)
        }
    }
}
