//
//  ComplicationController.swift
//  FrekWatch WatchKit Extension
//
//  Created by Hadrien Barbat on 2020-09-20.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let valueStore = ValueStore()
    let frekPlaceIdKey = "frekplaceId"
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        
        var descriptors = [CLKComplicationDescriptor]()
        let complicationCrowdIdentifier = "Crowd"
        let sortedFrekPlaces = valueStore.frekPlaces.sorted(by: { $0.name < $1.name })
        //let favorites = sortedFrekPlaces.filter { $0.favorite }
        
        for frekPlace in sortedFrekPlaces {
            print("⏳ Creating descriptor for complication \(frekPlace.id)")
            let crowdDescriptor = CLKComplicationDescriptor(
                identifier: complicationCrowdIdentifier + ": \(frekPlace.id)",
                displayName: frekPlace.name,
                supportedFamilies: CLKComplicationFamily.allCases,
                userInfo: [frekPlaceIdKey: frekPlace.id]
            )
            descriptors.append(crowdDescriptor)
        }
                
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        for descriptor in complicationDescriptors {
            guard let frekPlaceId = descriptor.userInfo?["frekPlaceId"] as? String,
                  let index = valueStore.frekPlaces.firstIndex(where: { $0.id == frekPlaceId })
                  else { continue }
            valueStore.frekPlaces[index].favorite = true
        }
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
        let frekPlaceId = complication.userInfo?[frekPlaceIdKey] as? String ?? valueStore.frekPlaces[0].id
        
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate(frekPlaceId, forDate: date)
        case .modularLarge:
            return createModularLargeTemplate(frekPlaceId, forDate: date)
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(frekPlaceId, forDate: date)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(frekPlaceId, forDate: date)
        case .circularSmall:
            return createCircularSmallTemplate(frekPlaceId, forDate: date)
        case .extraLarge:
            return createExtraLargeTemplate(frekPlaceId, forDate: date)
        case .graphicCorner:
            return createGraphicCornerTemplate(frekPlaceId, forDate: date)
        case .graphicCircular:
            return createGraphicCircleTemplate(frekPlaceId, forDate: date)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(frekPlaceId, forDate: date)
        case .graphicBezel:
            return createGraphicBezelTemplate(frekPlaceId, forDate: date)
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return createGraphicExtraLargeTemplate(frekPlaceId, forDate: date)
            } else {
                fatalError("Graphic Extra Large template is only available on watchOS 7.")
            }
        @unknown default:
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    private func createModularSmallTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!
        
        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateModularSmallStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    private func createModularLargeTemplate(_ frekPlaceId: String, forDate: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: text1, body1TextProvider: text2)
    }
    
    private func createUtilitarianSmallFlatTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let text = CLKSimpleTextProvider(text: "\(frekPlace.name): \(frekPlace.crowd)/\(frekPlace.fmi)", shortText: "\(frekPlace.crowd)/\(frekPlace.fmi)")
        let template = CLKComplicationTemplateUtilitarianSmallRingText(
            textProvider: text,
            fillFraction: 0.5,
            ringStyle: .closed
        )
        return template
    }
    
    // Return a utilitarian large template.
    private func createUtilitarianLargeTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!
        
        let text = CLKSimpleTextProvider(text: "\(frekPlace.name): \(frekPlace.crowd)/\(frekPlace.fmi)", shortText: "\(frekPlace.crowd)/\(frekPlace.fmi)")
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: text)
    }
    
    // Return a circular small template.
    private func createCircularSmallTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    // Return an extra large template.
    private func createExtraLargeTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    // Return a graphic template that fills the corner of the watch face.
    private func createGraphicCornerTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

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
    private func createGraphicCircleTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

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
    private func createGraphicRectangularTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        // Create the data providers.
        let crowdfloat = Float(frekPlace.crowd)
        let fmiFloat = Float(frekPlace.fmi)
        let percentage = Float(min(crowdfloat / fmiFloat, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, fmiFloat / 2, fmiFloat] as [NSNumber],
                                                   fillFraction: percentage)
        
        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        
        // Create the template using the providers.
        return CLKComplicationTemplateGraphicRectangularTextGauge(headerTextProvider: text1, body1TextProvider: text2, gaugeProvider: gaugeProvider)
    }
    
    // Return a circular template with text that wraps around the top of the watch's bezel.
    private func createGraphicBezelTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        // Create a graphic circular template with an image provider.
        let circle = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicCircular")))
        
        // Create the text provider.
        let crowdProvider = CLKSimpleTextProvider(text: frekPlace.crowd.description)

        // Create the bezel template using the circle template and the text provider.
        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle, textProvider: crowdProvider)
    }
    
    // Returns an extra large graphic template
    @available(watchOSApplicationExtension 7.0, *)
    private func createGraphicExtraLargeTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

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
