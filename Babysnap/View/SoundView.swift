//
//  SoundView.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/06/21.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit


class SoundView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let screenSize = UIScreen.main.bounds
        //UICollectionView を animate 表示
        self.frame = CGRect(
            x: 0,
            y: screenSize.height - (screenSize.height / 3.5),
            width: screenSize.width,
            height: screenSize.height / 3.5
        )
    }
}
