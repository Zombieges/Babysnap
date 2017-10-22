//
//  ShadowButton.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/06/29.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit

class ShadowButton: UIButton {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowOpacity = 0.8
        
        self.insets = UIEdgeInsetsMake(30, 30, 30, 30)
        
    }
}
