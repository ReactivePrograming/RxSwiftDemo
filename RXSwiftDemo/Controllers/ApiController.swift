//
//  ApiController.swift
//  RXSwiftDemo
//
//  Created by HaviLee on 2019/6/27.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import CoreLocation
import MapKit

class ApiController {

    struct Weather {
        let cityName: String
        let temperature: String
        let humidity: String
        let icon: String
        let lat: Double
        let lon: Double

        static let empty = Weather(
                    cityName: "unknown",
                    temperature: "-3000",
                    humidity: "0",
                    icon: "e",
                    lat: 0,
                    lon: 0)
        static let dummy = Weather(cityName: "RxCity", temperature: "20", humidity: "90", icon: "不错", lat: 0, lon: 0)
        
        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        func overlay() -> Overlay {
            let coordinates: [CLLocationCoordinate2D] = [
                CLLocationCoordinate2D(latitude: lat - 0.25, longitude: lon - 0.25),
                CLLocationCoordinate2D(latitude: lat + 0.25, longitude: lon + 0.25)
                ]
            let points = coordinates.map { MKMapPoint($0) }
            let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0))}
            let fittingRect = rects.reduce(MKMapRect.null) { (result, mapRect) -> MKMapRect in
                return result.union(mapRect)
            }
            return Overlay(icon: icon, coordinate: coordinate, boundingMapRect: fittingRect)
        }
        
        public class Overlay: NSObject, MKOverlay {
            var coordinate: CLLocationCoordinate2D
            var boundingMapRect: MKMapRect
            let icon: String
            
            init(icon: String, coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
                self.coordinate = coordinate
                self.boundingMapRect = boundingMapRect
                self.icon = icon
            }
        }
        
        public class OverlayView: MKOverlayRenderer {
            var overlayIcon: String
            init(overlay: MKOverlay, overlayIcon: String) {
                self.overlayIcon = overlayIcon
                super.init(overlay: overlay)
            }
            
            public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
                let imageReference = imageFromText(text: overlayIcon as NSString, font: UIFont.systemFont(ofSize: 32)).cgImage
                let theMapRect = overlay.boundingMapRect
                let theRect = rect(for: theMapRect)
                context.scaleBy(x: 1.0, y: -1.0)
                context.translateBy(x: 0.0, y: CGFloat(-theMapRect.size.height))
                context.draw(imageReference!, in: theRect)
                
            }
        }
    }

    static let shareInstance = ApiController()
    private let apiKey = "3f778bc5604a44c0b851d4b5f3eb5652"
    let baseURL = URL(string: "https://free-api.heweather.net/s6/weather/")!

    init() {
        Logging.URLRequests = { request in
            return true
        }
    }

    //MARK:return current weathrer

    func currentWeather(city: String) -> Observable<Weather> {
        /*
        return Observable.just(Weather(cityName: city, temperature: 20, humidity: 91, icon: iconNameToChar(icon: "01d")))
        */
        return buildRequest(pathComponent: "now", params: [("location", city)])
            .map({ json in
                let result = json["HeWeather6"]
                let basic = result[0]["basic"]
                let now = result[0]["now"]
                print("--------\(result)\n-------\(basic)")
                return Weather(cityName: basic["location"].string ?? "Unknown", temperature: now["tmp"].string ?? "-1000", humidity: now["hum"].string ?? "0", icon: now["cond_txt"].string ?? "e", lat: Double(basic["lat"].string!) ?? 0,lon: Double(basic["lon"].string!) ?? 0)
            })
    }
    
    func currentWeather(lat: Double, lon: Double) -> Observable<Weather> {
        return buildRequest(pathComponent: "now", params: [("location", "\(lat),\(lon)")])
            .map({ json in
                let result = json["HeWeather6"]
                let basic = result[0]["basic"]
                let now = result[0]["now"]
                print("--------\(result)\n-------\(basic)")
                return Weather(cityName: basic["location"].string ?? "Unknown", temperature: now["tmp"].string ?? "-1000", humidity: now["hum"].string ?? "0", icon: now["cond_txt"].string ?? "e", lat: basic["lat"].double ?? 0,lon: basic["lon"].double ?? 0)
            })
    }

    //net work request
    func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<JSON> {
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "key", value: apiKey)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1)}
            queryItems.append(keyQueryItem)
            urlComponents?.queryItems = queryItems
        } else {
            urlComponents?.queryItems = [keyQueryItem]
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        request.url = urlComponents?.url
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        return session.rx.data(request: request).map({
            try! JSON(data: $0)
        })
        
    }
    

}



public func iconNameToChar(icon: String) -> String {
    switch icon {
    case "01d":
        return "\u{f11b}"
    case "01n":
        return "\u{f110}"
    case "02d":
        return "\u{f112}"
    case "02n":
        return "\u{f104}"
    case "03d", "03n":
        return "\u{f111}"
    case "04d", "04n":
        return "\u{f111}"
    case "09d", "09n":
        return "\u{f116}"
    case "10d", "10n":
        return "\u{f113}"
    case "11d", "11n":
        return "\u{f10d}"
    case "13d", "13n":
        return "\u{f119}"
    case "50d", "50n":
        return "\u{f10e}"
    default:
        return "E"
    }
}

fileprivate func imageFromText(text: NSString, font: UIFont) -> UIImage {
    
    let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    text.draw(at: CGPoint(x: 0, y:0), withAttributes: [NSAttributedString.Key.font: font])
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image ?? UIImage(named: "weather")!
//    return UIImage(named: "weather")!
}
