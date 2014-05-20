//
//  ViewController.m
//  TestGray
//
//  Created by CharlieGao on 5/20/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ViewController.h"
#import "GrayScale.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *img = [UIImage imageNamed:@"image1.jpg"];
    GrayScale *grayimage = [[GrayScale alloc]init];
    
    
    UIImage *outputimg =  [grayimage convertToGrayscale: img];
    
    [self.imageView setImage:outputimg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
