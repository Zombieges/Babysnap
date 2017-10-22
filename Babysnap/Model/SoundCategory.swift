//
//  SoundCategoryModel.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/06/26.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

final class SoundCategory {
    var category: String = ""
    var charge: String = ""
    var sounds: [SoundItem] = []
    
    convenience required init(object: JSON) {
        self.init()
        self.category = object["category"].stringValue
        self.charge = object["charge"].stringValue
        
        let json: JSON = object["sounds"]
        sounds = json.arrayValue.map { SoundItem(object: $0) }
    }
    
    static func collection(object: JSON) -> [SoundCategory] {
        return object.arrayValue.map { SoundCategory(object: $0) }
    }
}
