//
//  HTTPHelper.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-05-23.
//

import Foundation

typealias Dict = [String: Any]

class HTTPHelper {
    
    static func convertToDictionaries(text: String) -> [Dict]? {
        if let data = text.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    return json
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    static func httpRequest(endpoint: String, method: HttpMethod, params: Dict?, completion: @escaping (Result<[Dict],Error>) -> Void) {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        
        print("Sending to \(endpoint.description)")
        if let json = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            print("Params \(json.description)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let data = data,
                let string = String(data: data, encoding: .utf8),
                let dict = HTTPHelper.convertToDictionaries(text: string)
            else {
                print("No usable response")
                return
            }
            
            completion(.success(dict))
            
            guard let response = response as? HTTPURLResponse else {
                print("response type is not HTTPURLResponse")
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                return
            }
        }
        task.resume()
    }
}

func decode<T: Decodable>(json: [String: Any]) -> T? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    } catch {
        print("Couldn't parse \(json) as \(T.self):\n\(error)")
        return nil
        
    }
}

struct FrekError: Decodable, Error {
    let type: Int
    let address: String
    let description: String
    
    init(_ description: String = "Unknown Error") {
        self.type = 0
        self.address = "frek error"
        self.description = description
    }
}
