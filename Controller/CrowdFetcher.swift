//
//  CrowdFetcher.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import Foundation

#if os(watchOS)
import ClockKit
#endif

let FrekWebsiteSuffix = [
    "Beaubourg": "beaubourg",
    "Châtelet": "chatelet-4eme",
    "Cherche Midi": "cherche-midi-6eme",
    "Cadet": "cadet-9eme",
    "Saint-Lazare": "saint-lazare-9eme",
    "Magenta": "magenta-10eme",
    "Charonne": "charonne-11eme",
    "République": "republique-11eme",
    "Bastille": "bastille-12eme",
    "Diderot": "diderot-12eme",
    "Nation": "nation-12eme",
    "Picpus": "picpus-12eme",
    "Tolbiac": "cercle-tolbiac-13eme",
    "Olympiades": "olympiades-13eme",
    "Raspail": "raspail-14eme",
    "Saint-Jacques": "saintjacques-14eme",
    "Lecourbe": "lecourbe-15eme",
    "Porte de Versailles": "pte-de-versailles-15eme",
    "Dauphine": "dauphine-16eme",
    "Batignolles": "batignolles-17eme",
    "Maillot": "maillot-17eme",
    "Montmarte": "montmartre-18eme",
    "Ornano": "ornano-18eme",
    "Championnet": "championnet-18eme",
    "Bolivar": "bolivar-19eme",
    "Porte de Bagnollet": "porte-de-bagnolet-20eme",
    "Chatillon": "chatillon"
]

class CrowdFetcher: ObservableObject {
        
    @Published var frekPlaces: [FrekPlace] {
        didSet {
            ValueStore().frekPlaces = frekPlaces
        }
    }
    
    @Published var refreshing = false
        
    var htmlGymDataSource = [String: String?]() // id -> html
    var htmlFrekDataSource = [String: String?]() // id -> html
    
    init() {
        frekPlaces = ValueStore().frekPlaces
        // fetchAll()
        fetchBackend()
    }
    
    func isDataSourceReady() -> Bool {
        !htmlGymDataSource.contains(where: { $0.value == nil }) && !htmlFrekDataSource.contains(where: { $0.value == nil })
    }
    
    func refresh() {
        // fetchAll()
        fetchBackend()
    }
    
    func updateData() {
        #if os(watchOS)
        ComplicationController.reloadAllComplicationsData()
        #endif
    }
    
    func fetchBackend() {
        refreshing = true
        HTTPHelper.httpRequest(endpoint: "https://fedutia.fr:8003", method: .get, params: nil) { result in
            switch result {
            case .success(let dictFrekPlaces):
                self.onFrekPlacesFetched(dictFrekPlaces)
                print("✅ \(self.frekPlaces.count) FrekPlacecs created!")
            case .failure(let err):
                print("❌ Error fetching backend: \(err)")
            }
        }
    }
    
    func onFrekPlacesFetched(_ frekPlaces: [Dict]) {
        frekPlaces.forEach { frekPlaceDict in
            if let frekPlace = FrekPlace.decode(frekPlaceDict) {
                DispatchQueue.main.async {
                    if let index = self.frekPlaces.firstIndex(where: { $0.id == frekPlace.id }) {
                        self.updateFrekPlace(at: index, frekPlace)
                    } else {
                        self.frekPlaces.append(frekPlace)
                    }
                }
            }
        }
    }
    
    func updateFrekPlace(at index: Int, _ frekPlace: FrekPlace) {
        frekPlaces[index].crowd = frekPlace.crowd
        frekPlaces[index].spotsAvailable = frekPlace.spotsAvailable
        frekPlaces[index].fmi = frekPlace.fmi
        frekPlaces[index].state = frekPlace.state
        // frekPlaces[index].image = frekPlace.image
    }
    
    
    func fetchAll() {
        refreshing = true
        let taskGroup = DispatchGroup()
        FrekWebsiteSuffix.forEach { (key, value) in
            taskGroup.enter()
            fetchGymHTML(with: value) { gymHTML in
                if let gymHTML = gymHTML, let id = CrowdParser.findFrekId(from: gymHTML) {
                    self.fetchFrekHTML(id: id) { frekHTML in
                        self.onFrekPlaceFetched(id, key, gymHTML, frekHTML)
                        taskGroup.leave()
                    }
                }
            }
        }
        taskGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.refreshing = false
            }
        }
    }
    
    func onFrekPlaceFetched(_ id: String, _ name: String, _ gymHTML: String?, _ frekHTML: String?) {
        guard let gymHTML = gymHTML, let frekHTML = frekHTML else {
            print("❌ Can't create Frekplace with id: \(id)")
            return
        }
        self.htmlFrekDataSource[id] = frekHTML
        self.htmlGymDataSource[id] = gymHTML
        
        DispatchQueue.main.async {
            if let index = self.frekPlaces.firstIndex(where: { $0.id == id }) {
                self.updateFrekPlace(at: index, frekHTML)
            } else {
                self.createFrekPlace(id, name, gymHTML, frekHTML)
            }
        }
    }
    
    func createFrekPlace(_ id: String, _ name: String, _ gymHTML: String, _ frekHTML: String) {
        frekPlaces.append(FrekPlace(id, name, gymHTML, frekHTML))
    }
    
    func updateFrekPlace(at index: Int, _ frekHTML: String) {
        frekPlaces[index].crowd = CrowdParser.findCrowd(from: frekHTML)
        frekPlaces[index].spotsAvailable = CrowdParser.findSpotsAvailable(from: frekHTML)
        frekPlaces[index].fmi = frekPlaces[index].crowd + frekPlaces[index].spotsAvailable
        frekPlaces[index].state = CrowdParser.findState(for: frekHTML)
    }
    
    func saveFrekPlaceImage(_ url: URL, _ name: String) {
        print("⏳ Saving Image...")
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location else {
                print("❌ Download error: ", error ?? "")
                return
            }
            do {
                let pathComponent = documents.appendingPathComponent(name)
                let filePath = pathComponent.path
                if !FileManager.default.fileExists(atPath: filePath) {
                    try FileManager.default.moveItem(at: location, to: pathComponent)
                    print("✅ Image Saved: \(filePath)")
                    return
                }
                print("❌ File exists: ")
            } catch {
                print("❌ Error moving items: \(error)")
            }
        }.resume()
    }
    
    func getFrekPlaceLocaleImageURL(_ frekPlaceWebImageUrl: URL) -> URL? {
        print("⏳ Get image from storage...")
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            if let url = fileURLs.first(where: { $0 == frekPlaceWebImageUrl }) {
                print("✅ Image found: \(url)")
                return url
            }
        } catch {
            print("❌ Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        print("❌ Image not found")
        return nil
    }
    
    func fetchGymHTML(with suffix: String, _ completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://www.cerclesdelaforme.com/salle-de-sport/\(suffix)/") else {
            print("❌ Unsupported gym suffix: \(suffix)")
            completion(nil)
            return
        }
        fetchHTML(url: url) { completion($0) }
    }
    
    func fetchFrekHTML(id: String, _ completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.cdf.resamania.com/cdf/public/attendances/\(id)/light?graph=true")!
        fetchHTML(url: url) { completion($0) }
    }
    
    func fetchHTML(url: URL, _ completion: @escaping (String?) -> Void) {
        print("⏳ Fetching html...")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error)")
                completion(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                print("❌ Invalid response or http code")
                completion(nil)
                return
            }
            if /*let mimeType = httpResponse.mimeType, mimeType == "text/html",*/
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                print("✅ Html fetched!")
                completion(html)
                return
            }
            print("❌ Error in mimeType? \(String(describing: httpResponse.mimeType))")
            completion(nil)
        }
        task.resume()
    }
}
