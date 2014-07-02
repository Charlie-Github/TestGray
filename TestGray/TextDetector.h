//
//  TextDetector.h
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextDetector : UIImage

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat) inputImage :(int)h :(int)w; // size.height size.weight





-(NSArray*)findTextArea: (UIImage*)inputImage; // main

-(cv::Mat)sharpen:(cv::Mat)inputImage;

-(cv::Mat)increaseContrast:(cv::Mat)inputMat;

-(cv::Mat)adaptiveThreshold:(cv::Mat)inputMat;

-(cv::Mat)removeBackground:(cv::Mat) inputMat;



@end
