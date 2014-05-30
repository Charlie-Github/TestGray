//
//  ViewController.m
//  TestGray
//
//  Created by CharlieGao on 5/20/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ViewController.h"
#import "GrayScale.h"
#import "UIImage+vImage.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import "ImagePreProcessor.h"

#import <opencv2/core/core_c.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Test Cases
    NSString *image_0 = @"lena.png";
    NSString *image_1 = @"image_book.jpg";
    NSString *image_2 = @"image_blue_poster.jpg";
    NSString *image_3 = @"image_bubble_poster.jpg";
    NSString *image_4 =@"image_blur.jpg";
    NSString *image_5 =@"image_gauss_blur.png";
    NSString *image_6 =@"image_black.jpg";
    NSString *image_7=@"image_white.png";
    NSString *image_8= @"IMG_0559.JPG";
    
    // Load image
    UIImage *img = [UIImage imageNamed: image_7];
    
    
	
	cv::Mat tempMat = [img CVMat];
    
    
    
    
    ImagePreProcessor *ipp = [[ImagePreProcessor alloc]init];
    
    tempMat = [ipp processImage:tempMat];
	
   
	
	img = [UIImage imageWithCVMat:tempMat]; //putting the image in an UIImage format
	
    
    
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
