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

class ApiController {

    struct Weather {
        let cityName: String
        let temperature: Int
        let humidity: Int
        let icon: String

        static let empty = Weather(cityName: "unknown", temperature: -3000, humidity: 0, icon: "e")
    }

    static let shareInstance = ApiController()
    private let apiKey = "12b2817fbec86915a6e9b4dbbd3d9039"
    let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!

    init() {
        Logging.URLRequests = { request in
            return true
        }
    }

    //MARK:return current weathrer

    func currentWeather(city: String) -> Observable<Weather> {
        return Observable.just(Weather(cityName: city, temperature: 20, humidity: 91, icon: iconNameToChar(icon: "01d")))
    }

    //net work request

    

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
