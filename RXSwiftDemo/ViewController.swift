//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by HaviLee on 2019/6/5.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.aztec
        setUpUI()
    }

    func setUpUI() {
        let fibs: [Int] = [1, 2, 3, 4]
        var squared: [Int] = []
        for fib in fibs {
            squared.append(fib * fib)
        }

//        fibs.sqc.map

        print(squared)

        let squares = fibs.map { (fib) -> Int in
            fib * fib
        }
    }

}

