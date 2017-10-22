//
//  PictureCollectionCell.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/11.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // 画像を表示する
    func setConfigure(assets: PHAsset) {
        let screenWidth = UIScreen.main.bounds.width
        
        let manager = PHImageManager()
        
        manager.requestImage(
            for: assets,
            targetSize: frame.size,
            contentMode: .aspectFill,
            options: nil,
            resultHandler: { [weak self] (image, info) in
                guard let wself = self else {
                    return
                }
                
                wself.photoImageView.image = image
            }
        )
    }
}
