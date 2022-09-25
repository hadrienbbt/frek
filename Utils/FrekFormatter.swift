import Foundation

class FrekFormatter: Formatter {
    lazy var isoFormatter = ISO8601DateFormatter()
    lazy var dateFormatter = DateFormatter()
    lazy var relativeFormatter = RelativeDateTimeFormatter()
    lazy var componentFormatter = DateComponentsFormatter()
    lazy var numberFormatter = NumberFormatter()
    
    func parseISOString(_ isoString: Any?) -> Date? {
        guard let isoString = isoString as? String else {
            print("❌ Error parsing iso string")
            return nil
        }
        return isoFormatter.date(from: isoString)
    }
    
    func string(fromChartDate date: Date) -> String {
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdEEEE")
        return dateFormatter.string(from: date).capitalizingFirstLetter()
    }
    
    func string(fromFrekTimeIndex index: Int) -> String {
        componentFormatter.unitsStyle = .abbreviated
        var components = DateComponents(hour: index / 2)
        let minutes = (index % 2) * 30
        if minutes > 0 {
            components.minute = minutes
        }
        return componentFormatter.string(from: components)!
    }
    
    func date(fromFrekTimeIndex index: Int, for day: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from: day)
        components.hour = index / 2
        components.minute = (index % 2) * 30
        return Calendar.current.date(from: components)!
    }
    
    func string(fromNumber number: NSNumber) -> String {
        return numberFormatter.string(from: number)!
    }
}
