//
//  CrowdParser.swift
//  Frek
//
//  Created by Hadrien Barbat on 2020-09-21.
//

import Foundation

class CrowdParser {
    
    static func findFrekId(from html: String) -> String? {
        print("⏳ Searching for frek id...")
        guard let frekId = CrowdParser.findSubstringBetween("https://api.cdf.resamania.com/cdf/public/attendances/", "/light?graph=", in: html) else {
            print("❌ Couldn't find frek id")
            return nil
        }
        print("✅ Frek id found: \(frekId)")
        return frekId
    }
    
    static func findImage(from html: String) -> URL {
        print("⏳ Searching for image...")
        let placeholder = URL(string: "https://www.cerclesdelaforme.com/wp-content/themes/CDLF/images/logo-big.png")!
        
        func reccursiveSearch(_ string: String) -> URL {
            if let afterImage = CrowdParser.findSubstringBetween("\" data-lazy-src=\"", nil, in: string) {
                if let image = CrowdParser.findSubstringBetween("\" data-lazy-src=\"", "\"", in: afterImage),
                   let url = URL(string: image),
                   !image.contains("assets/img/cards.jpg") {
                     print("✅ Image found: \(image)")
                     return url
                } else {
                    return reccursiveSearch(afterImage)
                }
            } else {
                print("❌ Couldn't find image, replacing with placeholder")
                return placeholder
            }
        }
        
        return reccursiveSearch(html)
    }
    
    static func findCrowd(from html: String) -> Int {
        print("⏳ Searching for crowd...")
        guard let attendanceClass = CrowdParser.findSubstringBetween("<div class=\"attendance\">", "</div>", in: html) else {
            print("❌ Couldn't find crowd")
            return 0
        }
        let strCrowd = attendanceClass.filter { "0"..."9" ~= $0 }
        print("✅ Crowd found: \(strCrowd)")
        return Int(strCrowd) ?? 0
    }
    
    static func findSpotsAvailable(from html: String) -> Int {
        print("⏳ Searching for spots available...")
        guard let valueClass = CrowdParser.findSubstringBetween("<span class=\"value\">", "</span>", in: html) else {
            print("❌ Couldn't find spots available")
            return 0
        }
        let strSpots = valueClass.filter { "0"..."9" ~= $0 }
        print("✅ spots available found: \(strSpots)")
        return Int(strSpots) ?? 0
    }
    
    static func findState(for html: String) -> Bool {
        print("⏳ Searching for state...")
        guard let startIndicatorClass = CrowdParser.findSubstringBetween("header .indicator {", "}", in: html),
              let background = CrowdParser.findSubstringBetween("background: ", " ", in: startIndicatorClass) else {
            print("❌ Couldn't find state")
            return false
        }
        let state = background == "#24B52A"
        print("✅ State found: \(state)")
        return state
    }
    
    static func findChart(for index: Int, in html: String) -> [String: [String: String]]? {
        guard let chart = CrowdParser.findSubstringBetween("new Chart(canvas\(index)", "options: {", in: html),
              let datasets = CrowdParser.findSubstringBetween("datasets: [", "pointStyle: \"line\"", in: chart),
              let minDataset = CrowdParser.findSubstringBetween("[", "]", in: datasets),
              let maxDataset = CrowdParser.findSubstringBetween("{\n                            data: [", "]", in: datasets) else {
            print("❌ Couldn't find chart")
            return nil
        }
        print("✅ Dataset found")
        print(minDataset)
        print(maxDataset)
        return nil
    }
    
    private static func findSubstringBetween(_ start: String, _ end: String?, in string: String) -> String? {
        guard let startIndex = string.endIndex(of: start) else {
            print("❌ Start not found: \(start)")
            return nil
        }
        let substring = string.suffix(from: startIndex)
        guard let end = end else { return String(substring) }
        guard let endIndex = substring.index(of: end) else {
            print("❌ End not found: \(end)")
            return nil
        }
        return String(substring.prefix(upTo: endIndex))
    }
}
