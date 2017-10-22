//
//  SoundItemModel.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/06/26.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

final class SoundItem {
    var picture: String = ""
    var sound: String = ""
    
    convenience required init(object: JSON) {
        self.init()
        self.picture = object["picture"].stringValue
        self.sound = object["sound"].stringValue
    }
    
    static func collection(object: JSON) -> [SoundItem] {
        return object.arrayValue.map { SoundItem(object: $0) }
    }
}
