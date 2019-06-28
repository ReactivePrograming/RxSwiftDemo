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

    let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.aztec
        setUpUI()
        //使用mock data
        ApiController.shareInstance.currentWeather(city: "RxSwift")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                self.tempLabel.text = "\(data.temperature)° C"
                self.weatherLabel.text = data.icon
                self.humidityLabel.text = "\(data.humidity)%"
                self.cityNameLabel.text = data.cityName
            }).disposed(by: bag)
        //use rxcocoa to observer the textview value
        /*
         这里searchCityName即是observe也是observer
        */
        self.searchCityName.rx.text
            .filter { ($0 ?? "").characters.count > 0 }
            .flatMap { text in
                return ApiController.shareInstance.currentWeather(city: text ?? "Error")
                .catchErrorJustReturn(ApiController.Weather.empty)
            }
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                self.tempLabel.text = "\(data.temperature)° C"
                self.weatherLabel.text = data.icon
                self.humidityLabel.text = "\(data.humidity)%"
                self.cityNameLabel.text = data.cityName
            })
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

