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
    let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit).asObservable()
            .map { self.searchCityName.text }
            .filter { ($0 ?? "").characters.count > 0 }
        let search = searchInput.flatMap { text in
            return ApiController.shareInstance.currentWeather(city: text ?? "北京")
                .catchErrorJustReturn(ApiController.Weather.dummy)
        }.asDriver(onErrorJustReturn: ApiController.Weather.dummy)
        
        let running = Observable.from([
            searchInput.map{ _ in true },
            search.map({ _ in
                false
            }).asObservable()
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

    }

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

}

