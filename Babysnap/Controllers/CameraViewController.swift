//
//  CameraViewController.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/05/15.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage
import SwiftyJSON
import CoreMotion
import Photos

class CameraViewController: UIViewController, CAAnimationDelegate, UINavigationBarDelegate {
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var showSoundView: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var soundItemsCollectionView: UICollectionView!
    @IBOutlet weak var soundCategoryCollectionView: UICollectionView!
    @IBOutlet weak var changeCropButton: UIButton!
    
    var soundsList: [SoundItem] = []
    var soundsCategory: [SoundCategory] = []
    
    lazy var sessionQueue: DispatchQueue = {
        DispatchQueue(label: "zombieges.BabyCam", qos: DispatchQoS.default)
    }()
    
    var cropImage = { (data: Setting) -> UIImage in
        return (data.cropSquare ? UIImage(named: "crop3_4") : UIImage(named: "crop9_16"))!
    }
    
    var soundCategoryButtons = [UIButton : ImageData]()
    var soundButtons = [UIButton : ImageData]()
    var audioPlayer: AVAudioPlayer!
    
    let focusView = UIView()
    var soundView = UIView()
    
    // GPUImageカメラ
    fileprivate lazy var camera: GPUImageStillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .back)
    
    // フィルターグループ
    fileprivate lazy var filterGroup = GPUImageFilterGroup()
    // 切り取り範囲
    fileprivate lazy var cropFilter = GPUImageCropFilter()
    // 美顔（バイラテラル）
    fileprivate lazy var beautifyFilter = GPUImageBeautifyFilter()
    // 明るさ
    fileprivate lazy var brightnessFilter = GPUImageBrightnessFilter()
    // コントラスト
    fileprivate lazy var contrastFilter = GPUImageContrastFilter()
    // 彩度
    fileprivate lazy var satureationFilter = GPUImageSaturationFilter()
    
    var manager: CMMotionManager!
    var photoOrientation: UIImageOrientation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カメラ認証
        launchCamere()
        // カメラロール認証
        launchPhotoLibrary()
        // GPUImage をセット
        setupCamera()
        // フォーカスジェスチャー生成
        setCameraFocusView()
        // サウンドビュー設定
        setupSoundView()
        // スクリーン設定
        setupDisplay()
        // モーション初期化
        initMotion()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        focus(tapPoint: self.view.center)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.getString(status: .toPreviewViewController) {
            let dest = segue.destination as! PreviewViewController
            dest.camera = camera
            dest.filterGroup = filterGroup
            dest.photoOrientation = photoOrientation
            
        } else if segue.identifier == Identifier.getString(status: .toSettingViewController) {
            _ = segue.destination as! SettingViewController
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func viewWillEnterForeground(_ notification: Notification?) {
        focus(tapPoint: self.view.center)
    }
}

extension CameraViewController {
    
    fileprivate func stopSoundButton() {
        let soundButtonTitleStop = NSLocalizedString("soundButtonTitleStop", comment: "")
        
        soundButton.setImage(UIImage(named: "sound_playing"), for: .normal)
        soundButton.setTitle(soundButtonTitleStop, for: .normal)
    }
    
    fileprivate func startSoundButton() {
        let soundButtonTitlePlay = NSLocalizedString("soundButtonTitlePlay", comment: "")
        
        soundButton.setImage(UIImage(named: "sound"), for: .normal)
        soundButton.setTitle(soundButtonTitlePlay, for: .normal)
    }
    
    // シャッターボタンで実行する
    @IBAction func takePhoto(_ sender: AnyObject) {
        defer { stopSoundButton() }
        
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            capturePhoto()
        } else {
            soundPlay(isSamplePlay: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.capturePhoto()
            }
        }
    }
    
    @IBAction func changeCamera(_ sender: Any) {
        camera.rotateCamera()
        camera.horizontallyMirrorFrontFacingCamera = true
        
        if let data = RealmHelper.objects(type: Setting.self)?.first {
            data.update {
                data.frontCamera = !data.frontCamera
            }
        }
        
        focus(tapPoint: self.view.center)
    }
    
    @IBAction func changeCrop(_ sender: ShadowButton) {
        if let data = RealmHelper.objects(type: Setting.self)?.first {
            data.update {
                data.cropSquare = !data.cropSquare
            }
        }
        
        camera.stopCapture()
        setupCamera()
        focus(tapPoint: self.view.center)
    }
    
    @IBAction func settingView(_ sender: Any) {
        let identifier = Identifier.getString(status: .toSettingViewController)
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    
    @IBAction func showSoundView(_ sender: UIButton) {
        guard soundView.isHidden else { return }
        
        soundView.isHidden = false
        takePhotoButton.isHidden = true
        showSoundView.isHidden = true
        soundButton.isHidden = true
        
        let screenSize = self.view.bounds.size
        //UICollectionView を animate 表示
        UIView.animate(withDuration: 0.4) {
            self.soundView.frame = CGRect(
                x: 0,
                y: screenSize.height - (screenSize.height / 3.5),
                width: screenSize.width,
                height: screenSize.height / 3.5
            )
        }
    }
    
    @IBAction func soundPlay(_ sender: UIButton) {
        if audioPlayer != nil && audioPlayer.isPlaying {
            startSoundButton()
            audioPlayer.stop()
        } else {
            stopSoundButton()
            soundPlay(isSamplePlay: false)
        }
    }
    
    func soundPlay(isSamplePlay: Bool) {
        if isSamplePlay { stopSoundButton() }
        
        guard let data = RealmHelper.objects(type: Setting.self)?.first,
              let sound = NSDataAsset(name: data.soundItem) else { return }
        
        let isSoundLoop = data.soundloop && !isSamplePlay
        
        sessionQueue.async {
            do {
                self.audioPlayer?.stop()
                
                // サイレントモードでも音出し
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                self.audioPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeMPEGLayer3)
                self.audioPlayer.delegate = self
                self.audioPlayer.volume = 1.0
                self.audioPlayer.numberOfLoops = isSoundLoop ? -1 : 0 // 1回再生。-1で無限ループ
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                
            } catch {
                print(error)
            }
        }
    }
    
    func tapOnFocus(_ sender: UITapGestureRecognizer) {
        guard soundView.isHidden  else {
            takePhotoButton.isHidden = false
            showSoundView.isHidden = false
            soundButton.isHidden = false
            
            let screenSize = self.view.bounds.size
            
            UIView.animate(withDuration: 0.4, animations: {
                self.soundView.frame = CGRect(
                    x: 0,
                    y: screenSize.height,
                    width: screenSize.width,
                    height: screenSize.height / 3.5
                )
                
            }, completion: { (finished: Bool) in
                self.soundView.isHidden = true
            })
            
            return
        }
        
        let tapPoint = sender.location(in: self.view)
        focus(tapPoint: tapPoint)
    }
    
    fileprivate func launchCamere() {
        DispatchQueue.main.async {
            switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            case .authorized:
                break
            case .notDetermined:
                self.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                    self.sessionQueue.resume()
                })
            case .denied:
                self.showCamereAlert()
            default:
                break
            }
        }
    }
    
    fileprivate func launchPhotoLibrary() {
        DispatchQueue.main.async {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                break
            case .denied:
                self.showPhotoLibraryAlert()
            case .restricted:
                break
            case .notDetermined:
                self.sessionQueue.suspend()
                PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                    self.sessionQueue.resume()
                }
            default:
                break
            }
        }
    }
    
    fileprivate func showCamereAlert() {
        UIAlertController.showAlertOKCancel(
            LocalizableConst.cameraLaunchTitle,
            message: LocalizableConst.cameraLaunchMessage,
            actiontitle: LocalizableConst.cameraLaunchActionTitle) { action in
                
            if action == .cancel { return }
            
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    fileprivate func showPhotoLibraryAlert() {
        UIAlertController.showAlertOKCancel(
            LocalizableConst.photoLaunchTitle,
            message: LocalizableConst.photoLaunchMessage,
            actiontitle: LocalizableConst.photoLaunchActionTitle) { action in
                
            if action == .cancel { return }
            
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    fileprivate func setupCamera() {
        guard let data = RealmHelper.objects(type: Setting.self)?.first else { return }
        
        changeCropButton.setImage(cropImage(data), for: .normal)
        
        camera.outputImageOrientation = .portrait
        
        if data.frontCamera {
            camera.rotateCamera()
            camera.horizontallyMirrorFrontFacingCamera = true
        }
        
        let screenRect = UIScreen.main.bounds
        
        cropFilter.cropRegion = data.cropSquare ? CGRect.presetPhoto : CGRect.presetHight
        cropFilter.forceProcessing(atSizeRespectingAspectRatio: CGSize(width: screenRect.width, height: screenRect.width))
        
        brightnessFilter.brightness = 0.01
        contrastFilter.contrast = 1.1
        satureationFilter.saturation = 0.8
        
        cropFilter.addTarget(beautifyFilter)
        beautifyFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(contrastFilter)
        contrastFilter.addTarget(satureationFilter)
        
        filterGroup.addFilter(cropFilter)
        filterGroup.addFilter(beautifyFilter)
        filterGroup.addFilter(brightnessFilter)
        filterGroup.addFilter(contrastFilter)
        filterGroup.addFilter(satureationFilter)
        
        filterGroup.initialFilters = [cropFilter]
        filterGroup.terminalFilter = satureationFilter
        
        camera.addTarget(filterGroup)
        filterGroup.addTarget(self.view as! GPUImageView)
        
        camera.startCapture()
    }
    
    /// SoundView を作成
    fileprivate func setupSoundView() {
        let json = loadJson()
        // サウンドカテゴリのセット
        soundsCategory = SoundCategory.collection(object: json!)
        // サウンドリストの初期セット
        soundsList = soundsCategory[0].sounds
        // サウンド選択画面の生成
        soundView = Bundle.main.loadNibNamed("SoundView", owner: self, options: nil)?.first! as! UIView
        
        let screenSize = self.view.bounds.size
        self.soundView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height / 3.5)
        
        soundItemsCollectionView.delegate = self
        soundItemsCollectionView.dataSource = self
        soundItemsCollectionView.register(SoundItemCell.self, forCellWithReuseIdentifier: "itemCell")
        self.soundView.addSubview(soundItemsCollectionView)
        
        soundCategoryCollectionView.delegate = self
        soundCategoryCollectionView.dataSource = self
        soundCategoryCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .bottom)
        soundCategoryCollectionView.register(SoundCategoryItemCell.self, forCellWithReuseIdentifier: "categoryCell")
        self.soundView.addSubview(soundCategoryCollectionView)
        
        self.view.addSubview(soundView)
    }
    
    
    /// ディスプレイ周りを生成
    fileprivate func setupDisplay(){
        // UINavigationBar を透過
        navigationController?.presentTransparentNavigationBar()
        navigationItem.backBarButtonItem?.title = ""
        
        // シャッターボタンレイアウト
        takePhotoButton.layer.cornerRadius = (self.view.layer.bounds.width / 5) / 2
        takePhotoButton.layer.borderWidth = 7
        takePhotoButton.layer.borderColor = UIColor.white.cgColor
        
        showSoundView.setTitle(LocalizableConst.showSoundViewText, for: .normal)
        soundButton.setTitle(LocalizableConst.soundButtonTextPlay, for: .normal)
        
        // 通知設定
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewWillEnterForeground(_:)),
            name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    /// 写真を撮影
    ///
    fileprivate func capturePhoto() {
        guard let isAutoSave = RealmHelper.objects(type: Setting.self)?.first?.autoSave else { return }
        if isAutoSave {
            //自動保存の場合は、オートセーブ処理
            // シャッターを切る場合、 alpha 変更して View をチラつかせる
            self.view.alpha = 0.1
            UIView.animate(withDuration: 0.6) {
                self.self.view.alpha = 1
            }
            
            camera.capturePhotoAsImageProcessedUp(toFilter: filterGroup) { (image, error) in
                guard let cgImage = image?.cgImage else { return }
                
                let orientationImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: self.photoOrientation)
                UIImageWriteToSavedPhotosAlbum(orientationImage, nil, nil, nil)
            }
            
            camera.resumeCameraCapture()
            
        } else {
            let identifier = Identifier.getString(status: .toPreviewViewController)
            performSegue(withIdentifier: identifier, sender: nil)
            
            camera.resumeCameraCapture()
        }
    }
    
    /// focusする
    ///
    /// - Parameter tapPoint: タップした座標
    fileprivate func focus(tapPoint: CGPoint) {
        let pointOfInterest = HBFocusUtils.convertToPointOfInterest(
            fromViewCoordinates: tapPoint,
            inFrame: self.view.bounds,
            with: .portrait,
            andFillMode: GPUImageFillModeType.init(1),
            mirrored: true
        )
        
        focusView.frame.size = CGSize(width: 120, height: 120)
        focusView.layer.cornerRadius = 60
        focusView.center = tapPoint
        focusView.backgroundColor = UIColor.white.withAlphaComponent(0)
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 2
        focusView.alpha = 1
        self.view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.focusView.frame.size = CGSize(width: 80, height: 80)
            self.focusView.layer.cornerRadius = 40
            self.focusView.center = tapPoint
        }, completion: { Void in
            UIView.animate(withDuration: 0.5, animations: {
                self.focusView.alpha = 0
            })
        })
        
        sessionQueue.async {
            HBFocusUtils.setFocus(pointOfInterest, for: self.camera.inputCamera)
        }
    }
    
    fileprivate func loadJson() -> JSON? {
        guard let path = Bundle.main.path(forResource: "SoundItem", ofType: "json") else { return nil }
        
        do{
            let jsonStr = try String(contentsOfFile: path)
            let json =  JSON.init(parseJSON: jsonStr)
            return json
        } catch{
            return nil
        }
    }

    /// モーション初期化
    fileprivate func initMotion() {
        manager = CMMotionManager()
        manager.accelerometerUpdateInterval = 0.01;
        
        manager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {
            (data:CMAccelerometerData?, error:Error?) -> Void in
            guard let data = data else { return }
            self.processAccelerometerData(data)
        })
    }
    
    fileprivate func processAccelerometerData(_ data: CMAccelerometerData) {
        let acceleration = data.acceleration
        
        switch (acceleration.x,acceleration.y) {
        case (let x, _) where x >= 0.75:
            self.photoOrientation = UIImageOrientation.right
        case (let x, _) where x <= -0.75:
            self.photoOrientation = UIImageOrientation.left
        case (_, let y) where y <= -0.75:
            self.photoOrientation = UIImageOrientation.up
        case (_, let y) where y >= 0.75:
            self.photoOrientation = UIImageOrientation.down
        default:
            self.photoOrientation = UIImageOrientation.up
        }
    }
    
}
