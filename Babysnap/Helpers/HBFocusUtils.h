//
//  HBFocusUtils.h
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/20.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

#ifndef HBFocusUtils_h
#define HBFocusUtils_h


#endif /* HBFocusUtils_h */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

@interface HBFocusUtils : NSObject

+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates inFrame:(CGRect)frame withOrientation:(UIDeviceOrientation)orientation andFillMode:(GPUImageFillModeType)fillMode mirrored:(BOOL)mirrored;
+ (void)setFocus:(CGPoint)focus forDevice:(AVCaptureDevice *)device;
@end
