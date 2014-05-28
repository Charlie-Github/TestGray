//
//  UIImage+blend.m
//  TestGray
//
//  Created by CharlieGao on 5/21/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "UIImage+Blend.h"

@implementation UIImage (Blend)

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    
    UIGraphicsBeginImageContext(self.size);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:rect];
    
    [overlayImage drawAtPoint:CGPointMake(0, 0) blendMode:blendMode alpha:alpha];
    
    UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

@end
