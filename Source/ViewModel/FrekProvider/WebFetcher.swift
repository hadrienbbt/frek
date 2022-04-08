import Foundation
import ClockKit

class WebFetcher: FrekplaceProvider {
    private let url: URL! = URL(string: "https://frek.fedutia.fr/frekplaces")
    
    func getFrekplaces() async -> [FrekPlace] {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let urlResponse = response as? HTTPURLResponse else { fatalError() }
            guard urlResponse.statusCode == 200 else {
                print("❌ Error fetching backend\n\(urlResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: urlResponse.statusCode))")
                return []
            }
            let frekplaces = try FrekDecoder().decode([FrekPlace].self, from: data)
            #if os(watchOS)
                await ComplicationController.reloadAllComplicationsData()
            #endif
            print("✅ Fetching finished with \(frekplaces.count) FrekPlaces created!")
            return processFavorites(frekplaces)
        } catch {
            print("❌ Error fetching backend: \(error)")
            return []
        }
    }
}
