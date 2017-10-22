//
//  PictureCollectionView.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/11.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotosCollectionViewController: UICollectionViewController {
    
    var photoAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        libraryRequestAuthorization()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionCell
        
        cell.setConfigure(assets: photoAssets[indexPath.row])
        return cell
    }
}

extension PhotosCollectionViewController {
    // カメラロールへのアクセス許可
    fileprivate func libraryRequestAuthorization() {
        PHPhotoLibrary.requestAuthorization({ [weak self] status in
            guard let wself = self else { return }
            
            switch status {
            case .authorized:
                wself.getAllPhotosInfo()
            case .denied:
                wself.showDeniedAlert()
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            }
        })
    }
    
    // カメラロールから全て取得する
    fileprivate func getAllPhotosInfo() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]

        let assets = PHAsset.fetchAssets(with: .image, options: options)
        assets.enumerateObjects({ (asset, index, stop) -> Void in
            self.photoAssets.append(asset as PHAsset)
        })
        
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
        })
    }
    
    // カメラロールへのアクセスが拒否されている場合のアラート
    fileprivate func showDeniedAlert() {
        let alert: UIAlertController = UIAlertController(
            title: "エラー",
            message: "「写真」へのアクセスが拒否されています。設定より変更してください。",
            preferredStyle: .alert
        )
        
        let cancel: UIAlertAction = UIAlertAction(
            title: "キャンセル",
            style: .cancel,
            handler: nil
        )
        
        let ok: UIAlertAction = UIAlertAction(
            title: "設定画面へ",
            style: .default,
            handler: { [weak self] (action) -> Void in
                guard let wself = self else {
                    return
                }
                wself.transitionToSettingsApplition()
            }
        )
        
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func transitionToSettingsApplition() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
