//
//  PlanetaryWidget.swift
//  PlanetaryWidget
//
//  Created by Daniel Ayala on 14/3/21.
//

import WidgetKit
import SwiftUI
import Intents

private var planetaryTimelineEntry = PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!, text: "Saturn", explanation: "Expanation Sample Text", shouldShowText: true)

struct PlanetaryTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> PlanetaryTimelineEntry {
        PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!, text: "Saturn", explanation: "Expanation Sample Text", shouldShowText: true)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (PlanetaryTimelineEntry) -> ()) {
//        let entry = PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!, text: "Saturn", explanation: "Expanation Sample Text", shouldShowText: configuration.shouldShowText as? Bool ?? false)
        completion(planetaryTimelineEntry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        PlanetaryWidgetProvider.getImageFromApi() { apodImageResponse in
            var entries: [PlanetaryTimelineEntry] = []
            var policy: TimelineReloadPolicy
            var entry: PlanetaryTimelineEntry
            
            switch apodImageResponse {
            case .Failure:
                entry = PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "Error")!, text: "Connection Error", shouldShowText: true)
                policy = .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)
                break
            case .Success(let image, let title, let explanation):
                entry = PlanetaryTimelineEntry(date: Date(), image: image, text: title, explanation: explanation, shouldShowText: configuration.shouldShowText as? Bool ?? false)
                
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
//                let timeToReload = Calendar.current.date(bySettingHour: configuration.LoadAt?.hour ?? 0,
//                                                         minute: configuration.LoadAt?.minute ?? 0,
//                                                         second: configuration.LoadAt?.second ?? 0,
//                                                         of: tomorrow)!
                policy = .after(tomorrow)
                break
            }
            planetaryTimelineEntry = entry
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: policy)
            completion(timeline)
        }
    }
}

struct PlanetaryTimelineEntry: TimelineEntry {
    let date: Date
    let image: UIImage
    var text: String = ""
    var explanation: String = ""
    var shouldShowText: Bool = true
}

struct PlanetaryWidgetEntryView : View {
    var entry: PlanetaryTimelineProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    func showImage() -> some View {
        return ZStack {
            Image(uiImage: entry.image)
                .resizable()
        }
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            ZStack {
                Image(uiImage: entry.image)
                    .resizable()
                if entry.shouldShowText {
                    CaptionOverlaySmall(entry: entry)
                }
            }
        case .systemMedium:
            if !entry.shouldShowText{
                showImage()
            } else {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.gray, .black, .gray]), startPoint: .top, endPoint: .bottom)
                    HStack {
                        VStack(alignment: .leading) {
                            Image(uiImage: entry.image)
                                .resizable()
                                .cornerRadius(6.0)
                        }
                        CaptionOverlayMedium(entry: entry)
                    }
                    .padding(.all)
                }
            }
        case .systemLarge:
            ZStack {
                Image(uiImage: entry.image)
                    .resizable()
                if entry.shouldShowText {
                    CaptionOverlayLarge(entry: entry)
                }
            }
        @unknown default: showImage()
        }
    }
}

struct CaptionOverlaySmall: View {
    var entry: PlanetaryTimelineProvider.Entry
    
    var body: some View {
        VStack {
            Spacer()
            Text(entry.text)
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .padding(6)
                .opacity(0.8)
                .background(ContainerRelativeShape().fill(Color.gray.opacity(0.5)))
        }
        .padding(6)
    }
}

struct CaptionOverlayMedium: View {
    var entry: PlanetaryTimelineProvider.Entry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.text)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .padding(6)
                    .opacity(0.8)
            }
            Spacer(minLength: 0)
        }
        .padding(.all)
        .background(ContainerRelativeShape().fill(Color(.lightGray)))
    }
}

struct CaptionOverlayLarge: View {
    var entry: PlanetaryTimelineProvider.Entry
    
    var body: some View {
        VStack {
            Text(entry.text)
                .font(.title3)
                .foregroundColor(.white)
                .bold()
                .shadow(color: .black, radius: 1, x: 1.0, y: 1.0)
                .padding(6)
                .opacity(0.8)
                .background(ContainerRelativeShape().fill(Color.gray.opacity(0.5)))
            
            
            Spacer()
            
            Text(entry.explanation)
                .font(.caption)
                .foregroundColor(.white)
                .padding(6)
                .opacity(0.8)
                .background(ContainerRelativeShape().fill(Color.gray.opacity(0.5)))
            
        }
        .padding(6)
    }
}


@main
struct PlanetaryWidget: Widget {
    let kind: String = "PlanetaryWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: PlanetaryTimelineProvider()) { entry in
            PlanetaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Random Astronomy Captions")
        .description("This Widget will catch your eye! Learn Astronomy from this amazing Captions provided by Nasa")
    }
}

struct PlanetaryWidget_Previews: PreviewProvider {
    static var previews: some View {
        PlanetaryWidgetEntryView(entry: PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "preview_image")!, text: "Saturn", explanation: "Expanation Sample Text"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        PlanetaryWidgetEntryView(entry: PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "preview_image")!, text: "Saturn", explanation: "Expanation Sample Text"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        PlanetaryWidgetEntryView(entry: PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "preview_image")!, text: "Saturn", explanation: "Expanation Sample Text"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        
        PlanetaryWidgetEntryView(entry: PlanetaryTimelineEntry(date: Date(), image: UIImage(named: "preview_image")!, text: "Saturn", explanation: "Expanation Sample Text"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .redacted(reason: .placeholder)
        
    }
}
