//
//  RxScheduler.swift
//  RXSwiftDemo
//
//  Created by 李旭 on 2019/7/3.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import Foundation
import RxSwift

class RxScheduler {
    
    let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    let bag = DisposeBag()
    let animal = BehaviorSubject(value: "[dog]")
    
    init() {
        animal
            .subscribeOn(MainScheduler.instance)
            .dump()
            .observeOn(globalScheduler)
            .dumpingSubscription()
            .disposed(by: bag)
        
        let fruit = Observable<String>.create { (observer) in
            observer.onNext("[apple]")
            sleep(2)
            observer.onNext("[pineapple]")
            sleep(2)
            observer.onNext("[strawberry]")
            return Disposables.create()
        }
//
        fruit
            .subscribeOn(globalScheduler)
            .dump()
            .observeOn(MainScheduler.instance)
            .dumpingSubscription()
            .disposed(by: bag)
        
//        let animalsThread = Thread() {
//            sleep(3)
//            self.animal.onNext("[cat]")
//            sleep(3)
//            self.animal.onNext("[tiger]")
//            sleep(3)
//            self.animal.onNext("[fox]")
//            sleep(3)
//            self.animal.onNext("[leopard]")
//        }
//
//        animalsThread.name = "Animals Thread"
//        animalsThread.start()
        
        
//        animal.subscribeOn(MainScheduler.instance)
//            .dump()
//            .observeOn(globalScheduler)
//            .dumpingSubscription()
//            .disposed(by:bag)
        
//        fruit.subscribeOn(globalScheduler)
//            .dump()
//            .observeOn(MainScheduler.instance)
//            .dumpingSubscription()
//            .disposed(by:bag)
        var mutableArray = [1,2,3]
        for a in mutableArray {
            print(a)
            mutableArray.removeLast()
        }
        print(mutableArray)
    }
    
}

