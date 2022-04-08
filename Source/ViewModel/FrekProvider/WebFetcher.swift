import Foundation
import ClockKit

class WebFetcher: FrekplaceProvider {
    private let url: URL! = URL(string: "https://frek.fedutia.fr/")
    
    func getFrekplaces() async -> [FrekPlace] {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
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
