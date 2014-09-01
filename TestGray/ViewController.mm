//
//  ViewController.m
//  TestGray
//
//  Created by CharlieGao on 5/20/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+vImage.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import "ImagePreProcessor.h"
#import "WordCorrector.h"
#import "TextDetector2.h"

#import <opencv2/core/core_c.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    NSDate *tdStart = [NSDate date];
    // Test Cases
    
    NSString *image_0 = @"image_gauss_blur.png";
    NSString *image_1 = @"IMG_0559.JPG";
    NSString *image_2 = @"Menu_2.JPG";
    NSString *image_3 = @"image_black.jpg";
    NSString *image_4 = @"Menu_4.PNG";
    NSString *image_5 = @"Menu_5.JPG";
    NSString *image_6 = @"IMG_2227.JPG";
    NSString *image_7 = @"IMG_2018.JPG";
    NSString *image_8 = @"IMG_0533.JPG";
    NSString *image_9 = @"IMG_0513.jpg";
    NSString *image_10 = @"IMG_20.jpg";
    NSString *image_11 = @"IMG_black_test.JPG";
    
    // Load image
    UIImage *img = [UIImage imageNamed: image_10];
	cv::Mat tempMat = [img CVMat];
    
    /*
    //charlie's image pre pro starts here
    ImagePreProcessor *ipp = [[ImagePreProcessor alloc]init];
    tempMat = [ipp processImage:tempMat];
    img = [UIImage imageWithCVMat:tempMat]; //convert UIimage into CV mat
    //charlie's image pre pro ends here
   */
    
    //charlie's text detection call
    TextDetector2 *td = [[TextDetector2 alloc]init];
    tempMat = [td findTextArea:img]; //putting the image in an UIImage format
    //text detection call end here
    
    
    img = [UIImage imageWithCVMat:tempMat]; //convert the mat back into UIImage format
	
    
    NSDate *tdFinish = [NSDate date];
    NSTimeInterval tdTime = [tdFinish timeIntervalSinceDate:tdStart];
    NSLog(@"-----------------ImagePrePro Time = %f", tdTime);
    
    
    /************************************* End OpenCV test *******************************************************/
    
    
    
    
    // show image
    [self.imageView setImage:img];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
