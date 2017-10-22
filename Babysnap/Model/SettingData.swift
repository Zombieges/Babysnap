//
//  SettingData.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/28.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Setting: Object {
    // 自動保存
    dynamic var autoSave = false
    // サウンドループ
    dynamic var soundloop = false
    // 選択した音
    dynamic var soundItem = ""
    // カメラ向きをフロントカメラに固定
    dynamic var frontCamera = false
    // １：１画面
    dynamic var cropSquare = false
}
