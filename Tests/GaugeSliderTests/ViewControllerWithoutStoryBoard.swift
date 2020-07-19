//
//  ViewControllerWithoutStoryBoard.swift
//  GaugeSliderTest
//
//  Created by Edgar Žigis on 23/08/2019.
//  Copyright © 2019 Edgar Žigis. All rights reserved.
//

import UIKit
import GaugeSlider

class ViewControllerWithoutStoryBoard: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.width
        
        let gaugeSlider = GaugeSliderView()
        applyStyle(to: gaugeSlider)
        gaugeSlider.frame = CGRect(x: width * 0.05, y: 150, width: width * 0.9, height: width * 0.9)
        view.addSubview(gaugeSlider)
        
        gaugeSlider.onProgressChanged = { [weak self] progress in
            print("Progress: \(progress)")
        }
        
        gaugeSlider.onButtonAction = { [weak self] in
            print("Action executed")
        }
        
        view.backgroundColor = .white
    }
    
    private func applyStyle(to v: GaugeSliderView) {
        v.blankPathColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1)
        v.fillPathColor = UIColor(red: 74/255, green: 196/255, blue: 192/255, alpha: 1)
        v.indicatorColor = UIColor(red: 94/255, green: 187/255, blue: 169/255, alpha: 1)
        v.unitColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
        v.placeholderColor = UIColor(red: 139/255, green: 154/255, blue: 158/255, alpha: 1)
        v.unitIndicatorColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.2)
        v.customControlColor = UIColor(red: 47/255, green: 190/255, blue: 169/255, alpha: 1)
        v.customControlButtonTitle = "• Auto"
        v.delegationMode = .immediate(interval: 3)
    }
}
