import Foundation

class LocalStore: FrekplaceProvider {
    func getFrekplaces() async -> [FrekPlace] {
        let ressourceName = "db"
        
        guard let path = Bundle.main.path(forResource: ressourceName, ofType: "json") else {
            print("❌ No file for ressource: \(ressourceName)")
            return []
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let frekplaces = try FrekDecoder().decode([FrekPlace].self, from: data)
            print("✅ JSON parsed finished with \(frekplaces.count) FrekPlaces created!")
            return processFavorites(frekplaces)
        } catch {
            print("❌ Error parsing JSON: \(error)")
            return []
        }
    }
}
