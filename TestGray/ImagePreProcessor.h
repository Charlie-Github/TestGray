//
//  ImagePreProcessor.h
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePreProcessor : UIImage

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w; // size.height size.weight

-(cv::Mat)laplacian:(cv::Mat) inputImage;



-(cv::Mat)processImage: (cv::Mat)inputImage;

-(cv::Mat)sharpen:(cv::Mat)inputImage;

-(cv::Mat)increaseContrast:(cv::Mat)inputMat;


-(cv::Mat)removeBackgroundBlack:(cv::Mat) inputMat;

-(cv::Mat)removeBackgroundWhite:(cv::Mat) inputMat;

-(cv::Mat)removeBackground2:(cv::Mat) inputMat;

-(cv::Mat)CalcBlockMeanVariance:(cv::Mat) Img : (float) blockSide;
@end
