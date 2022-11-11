import Foundation

class LocalStore: FrekplaceProvider {
    func getFrekplaces() async -> Result<[FrekPlace], FetchError> {
        let ressourceName = "db"
        
        guard let path = Bundle.main.path(forResource: ressourceName, ofType: "json") else {
            let fetchError = FetchError(message: "❌ No file for ressource: \(ressourceName)")
            return .failure(fetchError)
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let frekplaces = try FrekDecoder().decode([FrekPlace].self, from: data)
            print("✅ JSON parsed finished with \(frekplaces.count) FrekPlaces created!")
            return .success(processFavorites(frekplaces))
        } catch {
            let fetchError = FetchError(message: "❌ Error parsing JSON: \(error)")
            return .failure(fetchError)
        }
    }
}
