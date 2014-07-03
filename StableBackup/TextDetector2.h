//
//  TextDetector.h
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextDetector2 : UIImage

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat) inputImage :(int)h :(int)w; // size.height size.weight





-(NSMutableArray*)findTextArea: (UIImage*)inputImage; // main

-(cv::Mat)sharpen:(cv::Mat)inputImage;

-(cv::Mat)increaseContrast:(cv::Mat)inputMat;

-(cv::Mat)removeBackground:(cv::Mat) inputMat;



@end
