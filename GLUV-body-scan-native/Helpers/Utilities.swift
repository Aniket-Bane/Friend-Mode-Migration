//
//  Utilities.swift
//  FX
//
//  Created by Apple on 06/09/22.
//

import Foundation
import UIKit
import JGProgressHUD


let hud = JGProgressHUD()
let hud1 = JGProgressHUD()


func showSimpleHUD(in vw:UIView) {
    hud.backgroundColor = .white
    hud.style = .dark
    hud.vibrancyEnabled = true
    hud.textLabel.text = "Processing"
    hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
    hud.show(in: vw)
}

func dismissHUD(){
    hud.dismiss()
}

func showSimpleHUDWithoutBackground(in vw:UIView) {
    hud1.style = .dark
//    hud1.indicatorView = JGProgressHUDPieIndicatorView()
    hud1.vibrancyEnabled = true
    hud1.textLabel.text = "Creating Avatar"
    hud1.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
    hud1.show(in: vw)
}

func dismissHUDWithoutBackground(){
    hud1.dismiss()
}

func createNavBarButton(img:UIImage,action:Selector,vc:UIViewController)-> UIBarButtonItem {
    
    let button = UIButton(type: .custom)
    button.setImage(img, for:.normal)
    button.tintColor = UIColor.white
    button.addTarget(vc, action: action, for: .touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
    let barButton = UIBarButtonItem(customView: button)
    return barButton
    
}

func createNavBarButtonWithText(label:String,action:Selector,vc:UIViewController)-> UIBarButtonItem {
    
    let button = UIButton(type: .custom)
    button.setTitle(label, for: .normal)
    button.tintColor = UIColor.white
    button.addTarget(vc, action: action, for: .touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
    let barButton = UIBarButtonItem(customView: button)
    return barButton
}

// Email validation
func validate(YourEMailAddress: String) -> Bool {
    let REGEX: String
    REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
}


