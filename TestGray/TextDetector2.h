//
//  TextDetector.h
//  TestGray
//
//  Created by CharlieGao on 7/01/14.
//  Copyright (c) 2014 Edible Innovations LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextDetector2 : NSObject

-(cv::Mat)findTextArea: (UIImage*)inputImage; // main

@end
