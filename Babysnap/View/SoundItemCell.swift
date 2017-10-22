//
//  SoundItemCell.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/02.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import UIKit

class SoundItemCell: UICollectionViewCell {
    var imageButton: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        self.clipsToBounds = false
        
        let screenSize = UIScreen.main.bounds
        imageButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width / 7, height: screenSize.width / 7))

        self.contentView.addSubview(imageButton)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}
