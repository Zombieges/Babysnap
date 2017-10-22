//
//  RealmHelper.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/29.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import RealmSwift

public extension Object {
    
    /// Realm - 追加
    public func add() {
        let realm = try? Realm()
        try! realm?.write {
            //プライマリキーが定義されている場合はコレ
            //realm.add(self, update: true)
            realm?.add(self)
        }
    }
    
    
    /// Realm - 削除
    public func delete() {
        let realm = try? Realm()
        try! realm?.write({
            realm?.delete(self)
        })
    }
    
    
    /// Realm − 更新
    ///
    /// - Parameter updateBlock: updateBlock
    public func update(updateBlock: () -> ()) {
        let realm = try? Realm()
        try! realm?.write(updateBlock)
    }
}


/// Realmのヘルパークラス
public class RealmHelper {
    private init() {}
    
    public class func objects<T: Object>(type: T.Type) -> Results<T>? {
        let realm = try? Realm()
        return realm?.objects(type)
    }
    
    
    /// Realmオブジェクトを全て削除
    public class func deleteAll() {
        let realm = try? Realm()
        try! realm?.write {
            realm?.deleteAll()
        }
    }
}

