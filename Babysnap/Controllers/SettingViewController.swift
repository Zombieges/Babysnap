//
//  SettingViewController.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/29.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//


import UIKit

class SettingViewController: UIViewController, UINavigationBarDelegate {
    
    @IBAction func dismissCurrentView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
