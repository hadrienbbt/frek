//
//  FrekDecoder.swift
//  Frek
//
//  Created by Hadrien Barbat on 2021-06-02.
//

import Foundation
import Combine

class FrekDecoder: TopLevelDecoder {
    typealias Input = Data

    func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        do {
            guard let string = String(data: from, encoding: .utf8),
                  let data = string.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Dict] else {
                print("❌ Error parsing server response")
                fatalError()
            }
            let output = json.map { decode($0) } as! T
            return output
        } catch {
            print("❌ Error parsing server response \(error.localizedDescription)")
            fatalError()
        }
    }
    
    func decode(_ dict: Dict) -> FrekPlace? {
        guard let id = dict["frekId"] as? String,
            let name = dict["name"] as? String,
            let suffix = dict["suffix"] as? String,
            let crowd = dict["crowd"] as? Int,
            let spotsAvailable = dict["spotsAvailable"] as? Int,
            let fmi = dict["fmi"] as? Int,
            let state = dict["state"] as? Bool,
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double,
            let datasets = dict["datasets"] as? [Dict],
            let frekCharts = datasets.map ({ decode($0, fmi) }) as? [FrekChart]
            else {
                print("❌ Error parsing frekplace dictionnary")
                return nil
        }
        
        return FrekPlace(id: id, name: name, suffix: suffix, latitude: latitude, longitude: longitude, crowd: crowd, spotsAvailable: spotsAvailable, fmi: fmi, state: state, frekCharts: frekCharts)
    }
    
    func decode(_ dict: Dict, _ fmi: Int) -> FrekChart? {
        guard let date = FrekFormatter().parseISOString(dict["day"]),
              let start = dict["start"] as? [Int],
              let end = dict["end"] as? [Int] else {
            print("❌ Error parsing FrekChart dictionnary")
            return nil
        }
        let frekData: [Double] = start
            .enumerated()
            .reduce([]) { acc, val in
                let (index, element) = val
                var newAcc = acc
                newAcc.append(Double(element))
                if end.count > index {
                    newAcc.append(Double(end[index]))
                }
                return newAcc
            }
        return FrekChart(dataset: frekData, date: date, fmi: fmi)
    }
}
