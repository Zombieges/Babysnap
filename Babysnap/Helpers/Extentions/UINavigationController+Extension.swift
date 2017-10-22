//
//  UINavigationController+Extensions.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/22.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
    }
    
    public func hideTransparentNavigationBar() {
        navigationBar.setBackgroundImage(nil, for:UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
}
