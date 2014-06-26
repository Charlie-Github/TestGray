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
    
    // Load image
    UIImage *img = [UIImage imageNamed: image_1];
    
    
    //NSLog(@"test: %i", testMat.empty());
    /************************************* UIImage test Field Below ******************************************************/
    
    //GrayScale *grayimage = [[GrayScale alloc]init]; // GrayScale call
    //UIImage *outputimg =  [grayimage convertToGrayscale: img]; // GrayScale call
    //UIImage *outputimg = [img emboss]; // UIImage+vImage method call
    
    
    /************************************* End UIImage test Field ******************************************************/
    
    
    
    
    /************************************* OpenCV test Field Below ******************************************************/
    
    
	
	cv::Mat tempMat = [img CVMat];
    
    
    
    
	
	cv::Mat grayFrame, output;
	cv::Size size;
	size.height = 3;
	size.width = 3;
    
    ImagePreProcessor *ipp = [[ImagePreProcessor alloc]init];
    
    
    //sample code Please do not modified
	//cv::GaussianBlur(tempMat, tempMat, size, 0.8);
	//cv::adaptiveThreshold(tempMat, output, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
	//cv::GaussianBlur(output, output, size, 0.8);
    //end of sample
    
    
    
    
    // Wiener Filter remove noise
    //UIImage *tempimg = [UIImage imageWithCVMat:tempMat];
    //DeBlur *deb = [[DeBlur alloc] init];
    //UIImage *outputDeblur = [deb wienerFilter:tempimg];
    
//    cv::Canny(tempMat, output, 0.8,0.5); // detect edge
//    cv::GaussianBlur(output, output, cv::Size(0, 0), 3);
//    cv::addWeighted(output, 3, output, 0.1, 0, output);
    
    //cv::adaptiveThreshold(tempMat, output, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
    
    

    
    
    
    
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
