//
//  CameraViewController+UICollectionViewDelegate.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/06/10.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct ImageData {
    var indexPath = IndexPath()
}

extension CameraViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == soundItemsCollectionView.self {
            return soundsList.count
        } else {
            return soundsCategory.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if collectionView == soundItemsCollectionView.self {
            return UIEdgeInsetsMake(20, 20, 20, 20)
        } else {
            return UIEdgeInsetsMake(5, 5, 0, 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == soundItemsCollectionView.self {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! SoundItemCell
            cell.imageButton.setImage(UIImage.init(named: soundsList[indexPath.row].picture), for: .normal)
            cell.imageButton.addTarget(self, action: #selector(setSounds), for: .touchUpInside)
            
            var data = ImageData()
            data.indexPath = indexPath
            soundButtons[cell.imageButton] = data
            
            return cell
            
        } else if collectionView == soundCategoryCollectionView.self {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! SoundCategoryItemCell
            cell.imageButton.setImage(UIImage.init(named: soundsCategory[indexPath.row].category), for: .normal)
            cell.imageButton.addTarget(self, action: #selector(setCategory), for: .touchUpInside)
            
            var data = ImageData()
            data.indexPath = indexPath
            soundCategoryButtons[cell.imageButton] = data
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionReusableView", for: indexPath)
        
        return view
    }
    
    func setCategory(_ sender: UIButton) {
        for button in soundButtons.keys {
            button.layer.borderWidth = 0
        }
        
        if let categoryButton = soundCategoryButtons[sender] {
            // Category set
            soundCategoryCollectionView.selectItem(at: categoryButton.indexPath, animated: true, scrollPosition: .bottom)
            // souund item set
            soundsList = soundsCategory[categoryButton.indexPath.row].sounds
            // reload
            soundItemsCollectionView.reloadData()
        }
    }
    
    func setSounds(_ sender: UIButton) {
        for button in soundButtons.keys {
            button.layer.borderWidth = 0
        }
        
        guard let button = soundButtons[sender] else { return }
        
        if let data = RealmHelper.objects(type: Setting.self)?.first {
            data.update {
                data.soundItem = soundsList[button.indexPath.row].sound
            }
            
            self.soundPlay(isSamplePlay: true)
        }
        
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = UIColor.white.cgColor
    }
}
