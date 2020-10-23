//
//  ComplicationController.swift
//  FrekWatch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let crowdFetcher = CrowdFetcher()
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let complicationCrowdIdentifier = "Crowd"
        let crowdDescriptor = CLKComplicationDescriptor(identifier: complicationCrowdIdentifier, displayName: "Crowd", supportedFamilies: CLKComplicationFamily.allCases)

        let descriptors = [crowdDescriptor]
        
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
    // MARK: - Private Methods
    
    static func reloadAllComplicationsData() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        guard let complications = complicationServer.activeComplications else { return }
        complications.forEach { complicationServer.reloadTimeline(for: $0) }
    }
    
    // Return a timeline entry for the specified complication and date.
    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        
        // Get the correct template based on the complication.
        let template = createTemplate(forComplication: complication, date: date)
        
        // Use the template and date to create a timeline entry.
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    // Select the correct template based on the complication's family.
    private func createTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate(forDate: date)
        case .modularLarge:
            return createModularLargeTemplate(forDate: date)
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(forDate: date)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(forDate: date)
        case .circularSmall:
            return createCircularSmallTemplate(forDate: date)
        case .extraLarge:
            return createExtraLargeTemplate(forDate: date)
        case .graphicCorner:
            return createGraphicCornerTemplate(forDate: date)
        case .graphicCircular:
            return createGraphicCircleTemplate(forDate: date)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(forDate: date)
        case .graphicBezel:
            return createGraphicBezelTemplate(forDate: date)
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return createGraphicExtraLargeTemplate(forDate: date)
            } else {
                fatalError("Graphic Extra Large template is only available on watchOS 7.")
            }
        @unknown default:
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    private func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        let text1 = CLKSimpleTextProvider(text: "\(frekPlace.crowd) personnes sur place", shortText: frekPlace.crowd.description)
        let text2 = CLKSimpleTextProvider(text: "\(frekPlace.fmi) personnes maximum", shortText: frekPlace.fmi.description)
        return CLKComplicationTemplateModularSmallStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    private func createModularLargeTemplate(forDate: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        let text1 = CLKSimpleTextProvider(text: "\(frekPlace.crowd) personnes sur place", shortText: frekPlace.crowd.description)
        let text2 = CLKSimpleTextProvider(text: "\(frekPlace.fmi) personnes maximum", shortText: frekPlace.fmi.description)
        return CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: text1, body1TextProvider: text2)
    }
    
    private func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        let text = CLKSimpleTextProvider(text: "\(frekPlace.crowd)/\(frekPlace.fmi)", shortText: frekPlace.crowd.description)
        let template = CLKComplicationTemplateUtilitarianSmallRingText(
            textProvider: text,
            fillFraction: 0.5,
            ringStyle: .closed
        )
        return template
    }
    
    // Return a utilitarian large template.
    private func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        let text = CLKSimpleTextProvider(text: "\(frekPlace.crowd)/\(frekPlace.fmi)", shortText: frekPlace.crowd.description)
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: text)
    }
    
    // Return a circular small template.
    private func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        let text1 = CLKSimpleTextProvider(text: "\(frekPlace.crowd) personnes sur place", shortText: frekPlace.crowd.description)
        let text2 = CLKSimpleTextProvider(text: "\(frekPlace.fmi) personnes maximum", shortText: frekPlace.fmi.description)
        return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    // Return an extra large template.
    private func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        let text1 = CLKSimpleTextProvider(text: "\(frekPlace.crowd) personnes sur place", shortText: frekPlace.crowd.description)
        let text2 = CLKSimpleTextProvider(text: "\(frekPlace.fmi) personnes maximum", shortText: frekPlace.fmi.description)
        return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    // Return a graphic template that fills the corner of the watch face.
    private func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        // Create the data providers.
        let leadingValueProvider = CLKSimpleTextProvider(text: "0")
        leadingValueProvider.tintColor = .green
        
        let trailingValueProvider = CLKSimpleTextProvider(text: frekPlace.fmi.description)
        trailingValueProvider.tintColor = .red
        
        let crowdProvider = CLKSimpleTextProvider(text: frekPlace.crowd.description)

        let crowdfloat = Float(frekPlace.crowd)
        let fmiFloat = Float(frekPlace.fmi)
        let percentage = Float(min(crowdfloat / fmiFloat, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, fmiFloat / 2, fmiFloat] as [NSNumber],
                                                   fillFraction: percentage)
        
        let template = CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gaugeProvider, leadingTextProvider: leadingValueProvider, trailingTextProvider: trailingValueProvider, outerTextProvider: crowdProvider)
        return template
    }
    
    // Return a graphic circle template.
    private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        // Create the data providers.
        let crowdProvider = CLKSimpleTextProvider(text: frekPlace.crowd.description)
        let fmiProvider = CLKSimpleTextProvider(text: frekPlace.fmi.description)
        
        let crowdfloat = Float(frekPlace.crowd)
        let fmiFloat = Float(frekPlace.fmi)
        let percentage = Float(min(crowdfloat / fmiFloat, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, fmiFloat / 2, fmiFloat] as [NSNumber],
                                                   fillFraction: percentage)
        
        // Create the template using the providers.
        return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider, bottomTextProvider: fmiProvider, centerTextProvider: crowdProvider)
    }
    
    // Return a large rectangular graphic template.
    private func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        // Create the data providers.
        let crowdfloat = Float(frekPlace.crowd)
        let fmiFloat = Float(frekPlace.fmi)
        let percentage = Float(min(crowdfloat / fmiFloat, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, fmiFloat / 2, fmiFloat] as [NSNumber],
                                                   fillFraction: percentage)
        
        let text1 = CLKSimpleTextProvider(text: "\(frekPlace.crowd) personnes sur place", shortText: frekPlace.crowd.description)
        let text2 = CLKSimpleTextProvider(text: "\(frekPlace.fmi) personnes maximum", shortText: frekPlace.fmi.description)
        
        // Create the template using the providers.
        return CLKComplicationTemplateGraphicRectangularTextGauge(headerTextProvider: text1, body1TextProvider: text2, gaugeProvider: gaugeProvider)
    }
    
    // Return a circular template with text that wraps around the top of the watch's bezel.
    private func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        // Create a graphic circular template with an image provider.
        let circle = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicCircular")))
        
        // Create the text provider.
        let crowdProvider = CLKSimpleTextProvider(text: frekPlace.crowd.description)

        // Create the bezel template using the circle template and the text provider.
        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle, textProvider: crowdProvider)
    }
    
    // Returns an extra large graphic template
    @available(watchOSApplicationExtension 7.0, *)
    private func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = crowdFetcher.frekPlaces.first(where: { $0.name == "Magenta" })!
        
        // Create the data providers.
        let crowdfloat = Float(frekPlace.crowd)
        let fmiFloat = Float(frekPlace.fmi)
        let percentage = Float(min(crowdfloat / fmiFloat, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, fmiFloat / 2, fmiFloat] as [NSNumber],
                                                   fillFraction: percentage)
        
        let crowdProvider = CLKSimpleTextProvider(text: frekPlace.crowd.description)
        let fmiProvider = CLKSimpleTextProvider(text: frekPlace.fmi.description)
        
        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
            gaugeProvider: gaugeProvider,
            bottomTextProvider: fmiProvider,
            centerTextProvider: crowdProvider)
    }
}
