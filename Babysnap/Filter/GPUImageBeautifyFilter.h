//
//  GPUImageBeautifyFilter.h
//  Babysnap
//
//  Created by ExtYabecchi on 2017/07/06.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

#ifndef GPUImageBeautifyFilter_h
#define GPUImageBeautifyFilter_h


#endif /* GPUImageBeautifyFilter_h */

#import <GPUImage/GPUImage.h>

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end
