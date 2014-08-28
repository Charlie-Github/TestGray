//
//  ImagePreProcessor.h
//
//
//  Created by CharlieGao on 06/30/14.
//  Copyright (c) 2014 Edible Innovations LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePreProcessor : UIImage

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w; // size.height size.weight

-(cv::Mat)laplacian:(cv::Mat) inputImage;

-(cv::Mat)processImage: (cv::Mat)inputImage;

-(cv::Mat)sharpen:(cv::Mat)inputImage;

-(cv::Mat)increaseContrast:(cv::Mat)inputMat;

-(cv::Mat)process:(cv::Mat)inputRectImg;

@end
