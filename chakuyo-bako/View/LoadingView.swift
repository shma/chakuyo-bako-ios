//
//  LoadingView.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/28.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewChild: UIView!
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.clear
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        loadingViewChild.layer.cornerRadius = 8
        loadingViewChild.layer.shadowOpacity = 0.25
        loadingViewChild.layer.shadowRadius = 5
        loadingViewChild.layer.shadowOffset = CGSize(width: 0, height: 10)

        indicatorView.type = .squareSpin
        indicatorView.color = UIColor(red: 29 / 255, green: 150 / 255, blue: 120 / 255, alpha: 1)
        indicatorView.startAnimating()
    }
    
    func autoLayout(to toView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: toView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: toView.rightAnchor).isActive = true
    }

}
