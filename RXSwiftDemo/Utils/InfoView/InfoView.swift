//
//  InfoView.swift
//  RXSwiftDemo
//
//  Created by 李旭 on 2019/7/2.
//  Copyright © 2019 HaviLee. All rights reserved.
//

import UIKit

class InfoView: UIView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    private static var sharedView: InfoView!
    
    static func loadFromNib() -> InfoView {
        let nibName = "\(self)".split { $0 == "." }.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! InfoView
    }
    
    static func showInfo(viewController: UIViewController, message: String) {
        var displayVC = viewController
        if let tabController = viewController as? UITabBarController {
            displayVC = tabController.selectedViewController ?? viewController
        }
        if sharedView == nil {
            sharedView = loadFromNib()
            sharedView.layer.masksToBounds = true
            sharedView.layer.shadowColor = UIColor.darkGray.cgColor
            sharedView.layer.shadowOpacity = 1
            sharedView.layer.shadowOffset = CGSize(width: 0, height: 3)
            sharedView.layer.cornerRadius = 5
            sharedView.backgroundColor = UIColor.red
        }
        
        sharedView.textLabel.text = message
        if sharedView.superview == nil {
            let y = displayVC.view.safeAreaInsets.top
            sharedView.frame = CGRect(x: 12, y: y, width: displayVC.view.frame.size.width - 24, height: sharedView.frame.size.height)
            sharedView.alpha = 0.0
            
            displayVC.view.addSubview(sharedView)
            sharedView.fadeIn()
            
            sharedView.perform(#selector(fadeOut), with: nil, afterDelay: 3)
        }
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.03) {
            self.alpha = 1.0
        }
    }
    
    @objc func fadeOut() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        UIView.animate(withDuration: 0.33, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func closeButtonTaped(_ sender: Any) {
        fadeOut()
    }
    

}
