//
//  RouteData.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/28.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation

enum Identifier: String {
    case toPreviewViewController = "toPreviewViewController"
    case toSettingViewController = "toSettingViewController"
    
    static func getString(status: Identifier) -> String {
        return status.rawValue
    }
}
