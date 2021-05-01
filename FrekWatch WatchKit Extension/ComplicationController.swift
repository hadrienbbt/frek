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
                displayName: "Fréquentation à \(frekPlace.name)",
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
        let template = createTemplate(forComplication: complication, date: Date())
        handler(template)
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
        case .utilitarianSmall:
            return createUtilitarianSmallTemplate(frekPlaceId, forDate: date)
         case .utilitarianSmallFlat:
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
    
    private func createUtilitarianSmallTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let text = CLKSimpleTextProvider(text: "\(frekPlace.name): \(frekPlace.crowd)/\(frekPlace.fmi)", shortText: "\(frekPlace.crowd)/\(frekPlace.fmi)")
        let template = CLKComplicationTemplateUtilitarianSmallRingText(
            textProvider: text,
            fillFraction: 0.5,
            ringStyle: .closed
        )
        return template
    }
    
    private func createUtilitarianSmallFlatTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let text = CLKSimpleTextProvider(text: "\(frekPlace.name): \(frekPlace.crowd)/\(frekPlace.fmi)", shortText: "\(frekPlace.crowd)/\(frekPlace.fmi)")
        let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: text)
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
    
    func getGaugeProvider(_ crowd: Int, _ fmi: Int) -> CLKSimpleGaugeProvider {
        let gaugeColors: [UIColor] = [.green, .yellow, .red]
        let gaugeColorLocations = [0.0, 0.5, 1] as [NSNumber]
        let percentage = Float(min(Float(crowd) / Float(fmi), 1.0))
        return CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: gaugeColors,
                                                   gaugeColorLocations: gaugeColorLocations,
                                                   fillFraction: percentage)
    }
    
    func getImageProvider() -> CLKFullColorImageProvider{
        let image = UIImage(named: "Complication/Graphic Corner")!
        return CLKFullColorImageProvider(fullColorImage: image)
    }
    
    private func createGraphicCornerTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!
        let crowd = frekPlace.crowd
        let fmi = frekPlace.fmi

        return CLKComplicationTemplateGraphicCornerGaugeText(
            gaugeProvider: getGaugeProvider(crowd, fmi),
            leadingTextProvider: nil,
            trailingTextProvider: CLKSimpleTextProvider(text: fmi.description),
            outerTextProvider: CLKSimpleTextProvider(text: crowd.description)
        )
/*
 *  Support for image in corner
 *
        let image = UIImage(named: "Complication/Graphic Corner")!
        let imageProvider = CLKFullColorImageProvider(fullColorImage: image)
        let template = CLKComplicationTemplateGraphicCornerGaugeImage(gaugeProvider: gaugeProvider, leadingTextProvider: leadingValueProvider, trailingTextProvider: trailingValueProvider, imageProvider: imageProvider)
 */
    }
    
    // Return a graphic circle template.
    private func createGraphicCircleTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!
        let crowd = frekPlace.crowd
        let fmi = frekPlace.fmi

        return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(
            gaugeProvider: getGaugeProvider(crowd, fmi),
            bottomTextProvider: CLKSimpleTextProvider(text: fmi.description),
            centerTextProvider: CLKSimpleTextProvider(text: crowd.description)
        )
    }
    
    // Return a large rectangular graphic template.
    private func createGraphicRectangularTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!
        let name = frekPlace.name
        let crowd = frekPlace.crowd
        let fmi = frekPlace.fmi

        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        
        return CLKComplicationTemplateGraphicRectangularTextGauge(
            //headerImageProvider: getImageProvider(),
            headerTextProvider: CLKSimpleTextProvider(text: name),
            body1TextProvider: CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText),
            gaugeProvider: getGaugeProvider(crowd, fmi)
        )
        
    }
    
    // Return a circular template with text that wraps around the top of the watch's bezel.
    private func createGraphicBezelTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!

        let circularTemplate = createGraphicCircleTemplate(frekPlaceId, forDate: date)
        let image = CLKComplicationTemplateGraphicCircularImage(imageProvider: getImageProvider())
        let template = circularTemplate as? CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText ?? image
        
        return CLKComplicationTemplateGraphicBezelCircularText(
            circularTemplate: template,
            textProvider: CLKSimpleTextProvider(text: frekPlace.name)
        )
    }
    
    // Returns an extra large graphic template
    @available(watchOSApplicationExtension 7.0, *)
    private func createGraphicExtraLargeTemplate(_ frekPlaceId: String, forDate date: Date) -> CLKComplicationTemplate {
        let frekPlace = ValueStore().frekPlaces.first(where: { $0.id == frekPlaceId })!
        let crowd = frekPlace.crowd
        let fmi = frekPlace.fmi

        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
            gaugeProvider: getGaugeProvider(crowd, fmi),
            bottomTextProvider: CLKSimpleTextProvider(text: fmi.description),
            centerTextProvider: CLKSimpleTextProvider(text: crowd.description)
        )
    }
}
