//
//  Extension+Array.swift
//  RXSwiftDemo
//
//  Created by HaviLee on 2019/6/24.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import Foundation

public struct AdvancedSequence<Base> {
    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

public protocol SequenceCompatible {
    associatedtype CompatibleType
    static var sqc: AdvancedSequence<CompatibleType>.Type { get set }

    var sqc: AdvancedSequence<CompatibleType> {get set}
}

extension SequenceCompatible {
    public static var sqc: AdvancedSequence<Self>.Type {

        get {
            return AdvancedSequence<Self>.self
        }

        set {

        }
        
    }

    public var sqc: AdvancedSequence<Self> {
        get {
            return AdvancedSequence(self)
        }

        set {
            
        }
    }
}

extension Array: SequenceCompatible {
    //how
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}

//extension AdvancedSequence where Base: Array<Any> {
//    func aaa() {
//
//    }
//}
