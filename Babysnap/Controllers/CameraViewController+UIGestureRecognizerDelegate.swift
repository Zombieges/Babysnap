//
//  CameraViewController+UIGestureRecognizerDelegate.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/30.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit

extension CameraViewController: UIGestureRecognizerDelegate {
    
    func setCameraFocusView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnFocus(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isReturnView =
            (touch.view?.isDescendant(of: soundView))! ||
            (touch.view?.isDescendant(of: takePhotoButton))! ||
            (touch.view?.isDescendant(of: showSoundView))! ||
            (touch.view?.isDescendant(of: soundButton))! ||
            (touch.view?.isDescendant(of: changeCropButton))!
        
        return isReturnView ? false : true
    }
}
