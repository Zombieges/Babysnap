//
//  Filters.swift
//  Babysnap
//
//  Created by ExtYabecchi on 2017/08/27.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import UIKit
import GPUImage


/// GPUImageフィルター
struct Filter {

    /// Filterの種類
    ///
    /// - beautify: 美顔
    /// - contrast: コントラスト
    /// - saturation: 彩度
    /// - brightness: 輝度
    enum FilterType {
        case beautify
        case contrast
        case saturation
        case brightness
    }
    
    
    /// 美顔フィルター
//    static var beautify: GPUImageFilter {
//        let filter = GPUImageBeautifyFilter()
//        return filter
//    }
    
    /// コントラストフィルター
    static var contrast: GPUImageFilter {
        let filter = GPUImageContrastFilter()
        filter.contrast = 1.1
        return filter
    }
    

    /// 彩度フィルター
    static var saturation: GPUImageFilter {
        let filter = GPUImageSaturationFilter()
        filter.saturation = 0.8
        return filter
    }
    
    
    /// 輝度フィルター
    static var brightness: GPUImageFilter {
        let filter = GPUImageBrightnessFilter()
        filter.brightness = 0.01
        return filter
    }
    
}
