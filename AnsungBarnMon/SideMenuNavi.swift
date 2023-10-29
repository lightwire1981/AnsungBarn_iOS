//
//  SideMenuNavi.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/25/23.
//

import UIKit
import SideMenu

class SideMenuNavi: SideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
        self.leftSide = true
        self.menuWidth = self.view.frame.width * 0.8
//        self.blurEffectStyle = UIBlurEffect.Style.dark
    }
}

