import Foundation

class ValueStore {
    
    let suiteName = "group.fr.fedutia.Frek"
    
    var frekPlaces: [FrekPlace] {
        get {
            if let data = read("frekPlaces") as? Data,
                let frekPlaces = try? JSONDecoder().decode([FrekPlace].self, from: data) {
                return frekPlaces
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                write("frekPlaces", data)
            }
        }
    }

    private func read(_ key: String) -> Any? {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            print("❌ App group not configured for target")
            return UserDefaults.standard.object(forKey: key)
        }
        return userDefaults.object(forKey: key)
    }
    
    private func write(_ key: String, _ newValue: Any?) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            print("❌ App group not configured for target")
            return UserDefaults.standard.set(newValue, forKey: key)
        }
        userDefaults.set(newValue, forKey: key)
    }
}
