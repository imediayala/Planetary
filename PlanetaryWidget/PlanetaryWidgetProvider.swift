//
//  PlanetaryWidgetProvider.swift
//  PlanetaryWidgetExtension
//
//  Created by Daniel Ayala on 14/3/21.
//

import Foundation
import SwiftUI

enum PlanetaryProviderResponse {
    case Success(image: UIImage, title: String, explanation: String)
    case Failure
}

struct PlanetaryModelResponse: Decodable {
    var url: String
    var title: String
    var explanation: String
}

class PlanetaryWidgetProvider {
    static func getImageFromApi(completion: ((PlanetaryProviderResponse) -> Void)?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = Date()
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=GPa4mcUYiyYgwhj9U3TI0GtoXvBL3XT5z9viY0Ei&date=\(formatter.string(from: date))"
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetImage(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func parseResponseAndGetImage(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((PlanetaryProviderResponse) -> Void)?) {
        
        guard error == nil, let content = data else {
            print("error getting data from API")
            let response = PlanetaryProviderResponse.Failure
            completion?(response)
            return
        }
        
        var planetaryModelResponse: PlanetaryModelResponse
        do {
            planetaryModelResponse = try JSONDecoder().decode(PlanetaryModelResponse.self, from: content)
        } catch {
            print("error parsing URL from data")
            let response = PlanetaryProviderResponse.Failure
            completion?(response)
            return
        }
        
        let url = URL(string: planetaryModelResponse.url)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseImageFromResponse(data: data, urlResponse: urlResponse, error: error, planetaryModelResponse: planetaryModelResponse, completion: completion)
        }
        task.resume()
        
    }
    
    static func parseImageFromResponse(data: Data?, urlResponse: URLResponse?, error: Error?, planetaryModelResponse: PlanetaryModelResponse, completion: ((PlanetaryProviderResponse) -> Void)?) {
        
        guard error == nil, let content = data else {
            print("error getting image data")
            let response = PlanetaryProviderResponse.Failure
            completion?(response)
            return
        }
        
        let image = UIImage(data: content)!
        let response = PlanetaryProviderResponse.Success(image: image, title: planetaryModelResponse.title, explanation: planetaryModelResponse.explanation )
        completion?(response)
    }
}
