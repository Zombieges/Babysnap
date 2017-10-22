//
//  UIButton+Extention.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/09.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit

class ExpansionButton: UIButton {
    
    var insets = UIEdgeInsetsMake(0, 0, 0, 0)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var rect = bounds
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += insets.left + insets.right
        rect.size.height += insets.top + insets.bottom
        
        // 拡大したViewサイズがタップ領域に含まれているかどうかを返します
        return rect.contains(point)
    }
}
