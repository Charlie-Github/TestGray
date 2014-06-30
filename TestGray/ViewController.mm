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
#import "WordCorrector.h"

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
    
//    NSString *image_0 = @"lena.png";
//    NSString *image_1 = @"Menu_1.JPG";
//    NSString *image_2 = @"Menu_2.JPG";
    NSString *image_3 = @"image_black.jpg";
    NSString *image_4 = @"Menu_4.PNG";
    NSString *image_5 = @"Menu_5.JPG";
    NSString *image_6 = @"Menu_6.PNG";
//    NSString *image_7 = @"Menu_7.PNG";
    NSString *image_8 = @"IMG_0533.JPG";
    NSString *image_9 = @"IMG_0521.jpg";
    
    // Load image
    UIImage *img = [UIImage imageNamed: image_8];
	cv::Mat tempMat = [img CVMat];
    ImagePreProcessor *ipp = [[ImagePreProcessor alloc]init];
    
    tempMat = [ipp processImage:tempMat];
	
    img = [UIImage imageWithCVMat:tempMat]; //putting the image in an UIImage format
	
    for(int i = 0; i < 3000 ; i++){
    
    }
    
    
    

    //Text detector
    NSString *wrong_word = @"tost";
    WordCorrector *wc = [[WordCorrector alloc]init];
    NSString *correct_word = [wc correctWord: wrong_word];
//   NSLog(@"correct_word is: %@", correct_word);
    

    
    
    UIReferenceLibraryViewController *referenceLibraryViewController =
    [[UIReferenceLibraryViewController alloc] initWithTerm:@"apple"];

    
    
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
