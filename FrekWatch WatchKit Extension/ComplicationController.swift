import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let viewModel = FrekPlaceListViewModel()
    let frekPlaceIdKey = "frekplaceId"
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        var descriptors = [CLKComplicationDescriptor]()
        let frekPlaces: [FrekPlace]
        if !viewModel.favorites.isEmpty {
            frekPlaces = viewModel.favorites
        } else if !viewModel.sortedFrekPlaces.isEmpty {
            frekPlaces = viewModel.sortedFrekPlaces
        } else {
            frekPlaces = FrekPlace.samples
        }
        
        for frekPlace in frekPlaces {
            print("⏳ Creating descriptor for complication \(frekPlace.id)")
            let crowdDescriptor = CLKComplicationDescriptor(
                identifier: frekPlace.id,
                displayName: frekPlace.name,
                supportedFamilies: CLKComplicationFamily.allCases,
                userInfo: ["frekPlaceId": frekPlace.id]
            )
            descriptors.append(crowdDescriptor)
        }
                
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        for descriptor in complicationDescriptors {
            guard let frekPlaceId = descriptor.userInfo?["frekPlaceId"] as? String,
                  let index = viewModel.frekPlaces.firstIndex(where: { $0.id == frekPlaceId })
                  else { continue }
            viewModel.frekPlaces[index].favorite = true
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
        let frekPlaceId = complication.userInfo?[frekPlaceIdKey] as? String
        let frekPlace = viewModel.frekPlaces.first(where: { $0.id == frekPlaceId }) ?? FrekPlace.sample1
        
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate(frekPlace, forDate: date)
        case .modularLarge:
            return createModularLargeTemplate(frekPlace, forDate: date)
        case .utilitarianSmall:
            return createUtilitarianSmallTemplate(frekPlace, forDate: date)
         case .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(frekPlace, forDate: date)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(frekPlace, forDate: date)
        case .circularSmall:
            return createCircularSmallTemplate(frekPlace, forDate: date)
        case .extraLarge:
            return createExtraLargeTemplate(frekPlace, forDate: date)
        case .graphicCorner:
            return createGraphicCornerTemplate(frekPlace, forDate: date)
        case .graphicCircular:
            return createGraphicCircleTemplate(frekPlace, forDate: date)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(frekPlace, forDate: date)
        case .graphicBezel:
            return createGraphicBezelTemplate(frekPlace, forDate: date)
        case .graphicExtraLarge:
            if #available(watchOSApplicationExtension 7.0, *) {
                return createGraphicExtraLargeTemplate(frekPlace, forDate: date)
            } else {
                fatalError("Graphic Extra Large template is only available on watchOS 7.")
            }
        @unknown default:
            fatalError("*** Unknown Complication Family ***")
        }
    }
    
    private func createModularSmallTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateModularSmallStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    private func createModularLargeTemplate(_ frekPlace: FrekPlace, forDate: Date) -> CLKComplicationTemplate {
        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: text1, body1TextProvider: text2)
    }
    
    private func createUtilitarianSmallTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallRingText(
            textProvider: CLKSimpleTextProvider(text: "\(frekPlace.crowd)"),
            fillFraction: Float(min(Float(frekPlace.crowd) / Float(frekPlace.fmi), 1.0)),
            ringStyle: .closed
        )
        return template
    }
    
    private func createUtilitarianSmallFlatTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let text = CLKSimpleTextProvider(text: "\(frekPlace.name): \(frekPlace.crowd)/\(frekPlace.fmi)", shortText: "\(frekPlace.crowd)/\(frekPlace.fmi)")
        let template = CLKComplicationTemplateUtilitarianSmallFlat(textProvider: text)
        return template
    }
    
    // Return a utilitarian large template.
    private func createUtilitarianLargeTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let text = CLKSimpleTextProvider(text: "\(frekPlace.name): \(frekPlace.crowd)/\(frekPlace.fmi)", shortText: "\(frekPlace.crowd)/\(frekPlace.fmi)")
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: text)
    }
    
    // Return a circular small template.
    private func createCircularSmallTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let text1 = CLKSimpleTextProvider(text: frekPlace.name)
        let shortText = "\(frekPlace.crowd)/\(frekPlace.fmi)"
        let text2 = CLKSimpleTextProvider(text: "Fréquentation: \(shortText)", shortText: shortText)
        return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: text1, line2TextProvider: text2)
    }
    
    // Return an extra large template.
    private func createExtraLargeTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
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
    
    func getImageProvider(_ frekPlace: FrekPlace) -> CLKFullColorImageProvider{
        let image = UIImage(named: frekPlace.suffix)!
        return CLKFullColorImageProvider(fullColorImage: image)
    }
    
    private func createGraphicCornerTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
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
    private func createGraphicCircleTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let crowd = frekPlace.crowd
        let fmi = frekPlace.fmi

        return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(
            gaugeProvider: getGaugeProvider(crowd, fmi),
            bottomTextProvider: CLKSimpleTextProvider(text: fmi.description),
            centerTextProvider: CLKSimpleTextProvider(text: crowd.description)
        )
    }
    
    // Return a large rectangular graphic template.
    private func createGraphicRectangularTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
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
    private func createGraphicBezelTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let circularTemplate = createGraphicCircleTemplate(frekPlace, forDate: date)
        let image = CLKComplicationTemplateGraphicCircularImage(imageProvider: getImageProvider(frekPlace))
        let template = circularTemplate as? CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText ?? image
        
        return CLKComplicationTemplateGraphicBezelCircularText(
            circularTemplate: template,
            textProvider: CLKSimpleTextProvider(text: frekPlace.name)
        )
    }
    
    // Returns an extra large graphic template
    @available(watchOSApplicationExtension 7.0, *)
    private func createGraphicExtraLargeTemplate(_ frekPlace: FrekPlace, forDate date: Date) -> CLKComplicationTemplate {
        let crowd = frekPlace.crowd
        let fmi = frekPlace.fmi

        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
            gaugeProvider: getGaugeProvider(crowd, fmi),
            bottomTextProvider: CLKSimpleTextProvider(text: fmi.description),
            centerTextProvider: CLKSimpleTextProvider(text: crowd.description)
        )
    }
}
