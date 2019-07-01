//
//  CLLocationManager+Rx.swift
//  RXSwiftDemo
//
//  Created by 李旭 on 2019/6/28.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

//首先扩展CLLocationManager
extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

//定义代理类

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    public weak private(set) var locationManager: CLLocationManager?
    
    public init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {
            RxCLLocationManagerDelegateProxy(locationManager: $0)
        }
    }
}

//

extension Reactive where Base: CLLocationManager {
    public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))).map({ parameters in
            return parameters[1] as! [CLLocation]
        })
    }
    
}



