//
//  previewViewController.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/16.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import UIKit
import GPUImage
import SVProgressHUD

class PreviewViewController: UIViewController {

    @IBOutlet weak var previewImageView: UIImageView!
    
    var camera: GPUImageStillCamera?
    var previewImage: UIImage!
    var filterGroup: GPUImageFilterGroup?
    var photoOrientation: UIImageOrientation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nv = navigationController {
            let hidden = !nv.isNavigationBarHidden
            nv.setNavigationBarHidden(hidden, animated: false)
        }
        
        camera?.capturePhotoAsImageProcessedUp(toFilter: filterGroup) { (image, error) in
            guard let cgImage = image?.cgImage else { return }
            
            self.previewImage = image
            self.previewImageView.contentMode = .scaleAspectFit
            self.previewImageView.image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
            
            self.camera?.resumeCameraCapture()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func dismissCurrentView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "loading...")
        
        let image = UIImage(cgImage: (previewImage?.cgImage)!, scale: 1.0, orientation: photoOrientation)
        
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            SVProgressHUD.showSuccess(withStatus: LocalizableConst.savedText)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SVProgressHUD.popActivity()
            }
        }
    }
    
}
