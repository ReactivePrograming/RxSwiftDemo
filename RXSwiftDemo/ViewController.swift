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
    
    let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.aztec
        setUpUI()
        //使用mock data
        //MARK:- 第一步：调试通API
        /*
        ApiController.shareInstance.currentWeather(city: "RxSwift")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                self.tempLabel.text = "\(data.temperature)° C"
                self.weatherLabel.text = data.icon
                self.humidityLabel.text = "\(data.humidity)%"
                self.cityNameLabel.text = data.cityName
            }).disposed(by: bag)
        //use rxcocoa to observer the textview value
        */
        //MARK: - 第二步，使用RX，监听textfile的值的变化，然后通过请求网络展示天气
        /*
 
        self.searchCityName.rx.text
            .filter { ($0 ?? "").characters.count > 0 }
            .flatMapLatest { text in
                return ApiController.shareInstance.currentWeather(city: text ?? "Error")
                .catchErrorJustReturn(ApiController.Weather.empty)
            }
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                self.tempLabel.text = "\(data.temperature)° C"
                self.weatherLabel.text = data.icon
                self.humidityLabel.text = "\(data.humidity)%"
                self.cityNameLabel.text = data.cityName
            })
            .disposed(by: bag)
         */
        //MARK:- 第三步：使用数据bind
        //这里面首先使用textfiled的value是observable的
        /*
        let search = searchCityName.rx.text
            .filter { ($0 ?? "").characters.count > 0 }
            .flatMapLatest { text in
                return ApiController.shareInstance.currentWeather(city: text ?? "Beijing")
                    .catchErrorJustReturn(ApiController.Weather.empty)
            }
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
        //search是网络请求的observable，下面使用bind将producer绑定到Receiver上
        search.map { "\($0.temperature)°C"}
            .bind(to: tempLabel.rx.text)
            .disposed(by: bag)
        search.map { "\($0.icon)" }
            .bind(to: weatherLabel.rx.text)
            .disposed(by: bag)
        search.map { "\($0.humidity)" }
            .bind(to: humidityLabel.rx.text)
            .disposed(by: bag)
        search.map { "\($0.cityName)" }
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: bag)
        */
        //MARK:- 第四步：使用Traits And Driver
        //这里还使用了Controlproperty 和 ControlEvent
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

