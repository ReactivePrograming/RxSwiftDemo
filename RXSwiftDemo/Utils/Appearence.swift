//
//  Appearence.swift
//  RXSwiftDemo
//
//  Created by HaviLee on 2019/6/27.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import Foundation
import UIKit

struct Appearence {
    static func applyBottomLine(to view: UIView, color: UIColor = UIColor.ufoGreen) {
        let line = UIView(frame: CGRect.init(x: 0, y: view.frame.size.height-1, width: view.frame.size.width, height: 1))
        line.backgroundColor = color
        view.addSubview(line)
    }
}
