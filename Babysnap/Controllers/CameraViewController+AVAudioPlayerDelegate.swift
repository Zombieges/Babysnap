//
//  CameraViewController+AVAudioPlayerDelegate.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/08/11.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit

extension CameraViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        soundButton.setImage(UIImage(named: "sound"), for: .normal)
        soundButton.setTitle(LocalizableConst.soundButtonTextPlay, for: .normal)
        audioPlayer.stop()
    }
}
