//
//  TextDetector.h
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextDetector2 : NSObject

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(NSMutableArray*)findTextArea: (UIImage*)inputImage; // main

-(cv::Mat)sharpen:(cv::Mat)inputImage;

@end
