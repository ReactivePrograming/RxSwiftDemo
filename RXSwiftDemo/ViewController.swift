//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by HaviLee on 2019/6/5.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import MapKit

fileprivate let maxAttempts = 4

typealias Weather = ApiController.Weather

class ViewController: UIViewController {

    @IBOutlet weak var searchCityName: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var switchOn: UISwitch!
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    let bag = DisposeBag()
    let locationManager = CLLocationManager()
    var cache = [String: Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let util = RxScheduler()
        self.mapView.isHidden = true
        self.mapView.showsUserLocation = true
        view.backgroundColor = UIColor.aztec
        setUpUI()
        /*
         let textSearch = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
         let tempertature = switchOn.rx.controlEvent(.valueChanged).asObservable()
         let search = Observable.from([textSearch, tempertature])
         .merge()
         .map({ self.searchCityName.text })
         .filter { ($0 ?? "").characters.count > 0 }
         .flatMap { text in
         return ApiController.shareInstance.currentWeather(city: text ?? "Beijing")
         .catchErrorJustReturn(ApiController.Weather.empty)
         }
         .asDriver(onErrorJustReturn: ApiController.Weather.empty)
         
         search.map { result -> String in
         if self.switchOn.isOn {
         return "\(Int(Double(result.temperature)!*1.8+32))° F"
         } else {
         return "\(result.temperature)° C"
         }
         }
         .drive(tempLabel.rx.text)
         .disposed(by: bag)
         
         search.map { $0.icon }
         .drive(weatherLabel.rx.text)
         .disposed(by: bag)
         
         search.map { $0.cityName }
         .drive(cityNameLabel.rx.text)
         .disposed(by: bag)
         
         search.map { $0.humidity }
         .drive(humidityLabel.rx.text)
         .disposed(by: bag)
         
        */
        //MARK:- 第一步：增加UIActivityIndicatorView
        //这个是search input Observable
        
//        switchOn.rx.controlEvent(.valueChanged).asObservable().subscribe { (event) in
//            let alert = UIAlertController(title: "ce", message: "dd", preferredStyle: .alert)
//            let action = UIAlertAction.init(title: "确认", style: .default) { (alert) in
//                UIApplication.shared.open(URL(string: "https://testflight.apple.com/join/ua0oicPc")!, options: [:], completionHandler: nil)
//            }
//            alert.addAction(action)
//            self.present(alert, animated: false, completion: nil)
//        }
        
        //首先获取用户授权
        let geoInput = placeButton.rx.tap.asObservable()
            .do(onNext: {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            })
        
        let currentLocation = locationManager.rx.didUpdateLocations
            .map { locations in
                return locations[0]
            }
            .filter { (location) -> Bool in
                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
            }
        
        let geoLocation = geoInput.flatMap {
            return currentLocation.take(1)
        }
        
        let geoSearch = geoLocation.flatMap { location in
            return ApiController.shareInstance.currentWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                .catchErrorJustReturn(ApiController.Weather.dummy)
        }
        
        mapButton.rx.tap
            .subscribe(onNext: {
                self.mapView.isHidden = !self.mapView.isHidden
            })
            .disposed(by: bag)
        
        
        mapView.rx.setDelegate(self)
            .disposed(by: bag)
        
        //测试定位成功
//        let updateLocation = locationManager.rx.didUpdateLocations.subscribe { (locations) in
//            print(locations)
//        }
//        .disposed(by: bag)
        let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
            return e.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                if attempt >= maxAttempts - 1 {
                    return Observable.error(error)
                } else if let casted = error as? ApiController.ApiError, casted == .invalidKey {
                    return Observable.error(error)
                }
                print("== retrying after \(attempt + 1) seconds ==")
                return Observable<Int>.timer(Double(attempt + 1), scheduler: MainScheduler.instance).take(1)
            }
        }
        
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .map { self.searchCityName.text }
            .filter { ($0 ?? "").characters.count > 0 }
        let textSearch = searchInput.flatMap { text in
            return ApiController.shareInstance.currentWeather(city: text ?? "北京")
                .do(onNext: { (data) in
                    if let text = text {
                        self.cache[text] = data
                    }
                }, onError: { [weak self] e in
                    guard let strongSelf = self else { return }
                    DispatchQueue.main.sync {
                        strongSelf.showError(error: e)
                    }
                })
                .retryWhen(retryHandler)
                .catchError({ (error) in
                    if let text = text, let cacheData = self.cache[text] {
                        return Observable.just(cacheData)
                    } else {
                        return Observable.just(ApiController.Weather.empty)
                    }
                })
        }
        
        let mapInput = mapView.rx.regionDidChangeAnimated
            .skip(1)
            .map { _ in self.mapView.centerCoordinate }
        
        let mapSearch = mapInput.flatMap { coordinate in
            return ApiController.shareInstance.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        
        let search = Observable.from([geoSearch, textSearch, mapSearch])
            .merge()
            .asDriver(onErrorJustReturn: ApiController.Weather.dummy)
        
        let running = Observable.from([
            searchInput.map{ _ in true },
            geoInput.map({ _ in true }),
            search.map({ _ in false })
                .asObservable()
            ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        running
            .skip(1)
            .drive(self.indicatorView.rx.isAnimating)
            .disposed(by: bag)
        
        running
            .drive(tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(weatherLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(cityNameLabel.rx.isHidden)
            .disposed(by: bag)
        
        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(weatherLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityNameLabel.rx.text)
            .disposed(by: bag)
        search.map { [$0.overlay()] }
            .drive(mapView.rx.overlays)
            .disposed(by: bag)

    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
//            let alert = UIAlertController(title: "ce", message: "dd", preferredStyle: .alert)
//            let action = UIAlertAction.init(title: "确认", style: .default) { (alert) in
//                UIApplication.shared.open(URL(string: "https://testflight.apple.com/join/ua0oicPc")!, options: [:], completionHandler: nil)
//            }
//            alert.addAction(action)
//            self.present(alert, animated: false, completion: nil)
//        }
//    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    

    private func setUpUI() {
        Appearence.applyBottomLine(to: searchCityName)
        searchCityName.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        weatherLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
    
    func showError(error e: Error) {
        if let e = e as? ApiController.ApiError {
            switch (e) {
            case .cityNotFound:
                InfoView.showInfo(viewController: self, message: "City not found")
            case .serverFailure:
                InfoView.showInfo(viewController: self, message: "Server Down")
            case .invalidKey:
                InfoView.showInfo(viewController: self, message: "key not found")
            }
        } else {
            InfoView.showInfo(viewController: self, message: "An error not found")
        }
    }

}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? ApiController.Weather.Overlay {
            let overlayView = ApiController.Weather.OverlayView(overlay: overlay, overlayIcon: overlay.icon)
            return overlayView
        }
        return MKOverlayRenderer()
    }
}

