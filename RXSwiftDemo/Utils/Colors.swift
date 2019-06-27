//
//  Colors.swift
//  RXSwiftDemo
//
//  Created by HaviLee on 2019/6/13.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import Foundation
import UIKit

func colorFromDecimalRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

extension UIColor {

    static var aztec: UIColor {
        return colorFromDecimalRGB(38, 39, 41)
    }

    var lightCream: UIColor {
        return colorFromDecimalRGB(232, 234, 221)
    }

}

extension Array {
    
}
