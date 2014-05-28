//
//  UIImage+blend.h
//  TestGray
//
//  Created by CharlieGao on 5/21/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blend)

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end