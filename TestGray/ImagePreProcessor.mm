//
//  ImagePreProcessor.m
//
//
//  Created by CharlieGao on 6/30/14.
//  Copyright (c) 2014 Edible Innovations LLC. All rights reserved.
//
#import "ImagePreProcessor.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"

using namespace cv;
using namespace std;

@implementation ImagePreProcessor



-(cv::Mat)processImage: (cv::Mat)inputImage{
    
    NSLog(@"ImagePrePro: Called!");
    
    cv::Mat output;
    int backGround = 1;
    backGround = [self checkBackground2:inputImage];
    
    if (backGround == 0) {
        NSLog(@"ImagePrePro: Black Backgroud");
        
        inputImage = [self adaptiveThresholdBlack:inputImage];
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
        
    }
    else if(backGround == 1){
        NSLog(@"ImagePrePro: Normal Image");
        
        inputImage = [self adaptiveThreshold:inputImage];
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
        
    }
    else if(backGround == 2 ){
        //test case.
        NSLog(@"ImagePrePro: Test mode 1 ");
        cv::cvtColor(inputImage, inputImage, cv::COLOR_BGRA2BGR);
        
        inputImage = [self adaptiveThreshold:inputImage];
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
    }
    else if(backGround == 10){
        NSLog(@"ImagePrePro: Test mode 2");
        
    }
    
    return inputImage;
    
    
    
}



//------------Basic method

-(cv::Mat)toGrayMat:(UIImage *) inputImage{
    
    cv::Mat matImage = [inputImage CVGrayscaleMat];
    return matImage;
}

-(cv::Mat)erode:(cv::Mat)img{
    
    int erosion_elem = 2;
    int erosion_size = 1;
    cv::Mat erosion_dst;
    int erosion_type;
    if( erosion_elem == 0 ){ erosion_type = cv::MORPH_RECT; }
    //else if( erosion_elem == 1 ){ erosion_type = cv::MORPH_CROSS; }
    else { erosion_type = cv::MORPH_ELLIPSE; }
    
    cv::Mat element = getStructuringElement( erosion_type,
                                            cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                            cv::Point( erosion_size, erosion_size ) );
    /// Apply the erosion operation
    erode( img, erosion_dst, element );
    return erosion_dst;
    
}


-(cv::Mat)dilate:(cv::Mat)img{
    
    cv::Mat dilation_dst;
    int dilation_type;
    int dilation_elem = 1;
    int dilation_size = 1;
    
    if( dilation_elem == 0 ){ dilation_type = cv::MORPH_RECT; }
    //else { dilation_type = cv::MORPH_CROSS; }
    else { dilation_type = cv::MORPH_ELLIPSE; }
    
    cv::Mat element = getStructuringElement( dilation_type,
                                            cv::Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                            cv::Point( dilation_size, dilation_size ) );
    /// Apply the dilation operation
    dilate( img, dilation_dst, element );
    
    return dilation_dst;
    
}



-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w{
    
    cv::Mat output;
    cv::Size size;
	size.height = h;
	size.width = w;
    cv::GaussianBlur(inputImage, output, size, 0.8);
    return output;
    
}

-(cv::Mat)laplacian:(cv::Mat)inputImage{
    
    cv::Mat output;
    cv::Mat kernel = (cv::Mat_<float>(3, 3) << 0, -1, 0, -1, 4, -1, 0, -1, 0); //Laplacian operator
    cv::filter2D(inputImage, output, output.depth(), kernel);
    return output;
    
}

-(cv::Mat)sharpen:(cv::Mat)inputImage{
    cv::Mat output;
    cv::GaussianBlur(inputImage, output, cv::Size(0, 0), 10);
    cv::addWeighted(inputImage, 1.5, output, -0.5, 0, output);
    return output;
}



-(cv::Mat)increaseContrast:(cv::Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    
    
    std::vector<cv::Mat> channels;
    
    cv::Mat img_hist_equalized;
    
    cv::cvtColor(inputMat, img_hist_equalized, cv::COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    
    cv::split(img_hist_equalized,channels); //split the image into channels
    
    cv::equalizeHist(channels[0], channels[0]); //equalize histogram on the 1st channel (Y)
    
    cv::merge(channels,img_hist_equalized); //merge 3 channels including the modified 1st channel into one image
    
    cv::cvtColor(img_hist_equalized, img_hist_equalized, cv::COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_hist_equalized;
    
}
//------------/Basic method


//------Threshold method

-(cv::Mat)adaptiveThreshold:(cv::Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    //the first channel of YCrCb is for grayscale representation, feeding into adaptiveThrenshold function whose input is sigle channel
    
    std::vector<cv::Mat> channels;
    
    cv::Mat img_threshold;
    cv::cvtColor(inputMat, img_threshold, cv::COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    cv::split(img_threshold,channels); //split the image into channels
    
    
    //cv::fastNlMeansDenoising(channels[0], channels[0], 3.0f, 7, 35);
    
    //--Simple threshold, removing little noisy
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(channels[0], channels[0], size, 0.5);
    cv::threshold(channels[0], channels[0], 0,255, cv::THRESH_TRUNC | cv::THRESH_OTSU);
    
    //--Simple end here
    
    cv::adaptiveThreshold(channels[0], channels[0], 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY,11, 2);
    cv::merge(channels,img_threshold); //merge 3 channels including the modified 1st channel into one image
    cv::cvtColor(img_threshold, img_threshold, cv::COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_threshold;
}


-(cv::Mat)adaptiveThresholdBlack:(cv::Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    //the first channel of YCrCb is for grayscale representation, feeding into adaptiveThrenshold function whose input is sigle channel
    
    std::vector<cv::Mat> channels;
    
    cv::Mat img_threshold;
    cv::cvtColor(inputMat, img_threshold, cv::COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    cv::split(img_threshold,channels); //split the image into channels
    
    
    //cv::fastNlMeansDenoising(channels[0], channels[0], 3.0f, 7, 11);
    
    //--Simple threshold, removing little noisy
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(channels[0], channels[0], size, 0.5);
    //reverse color
    
    cv::bitwise_not(channels[0], channels[0]);
    
    cv::threshold(channels[0], channels[0], 0,255, cv::THRESH_TRUNC | cv::THRESH_OTSU);
    
    //--Simple end here
    
    cv::adaptiveThreshold(channels[0], channels[0], 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY,11, 2);
    cv::merge(channels,img_threshold); //merge 3 channels including the modified 1st channel into one image
    cv::cvtColor(img_threshold, img_threshold, cv::COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_threshold;
    
}

//------/Threshold method


-(int)checkBackground2:(cv::Mat)inputRectImg{
    
    std::vector<cv::Mat> channels;
    cv::cvtColor(inputRectImg, inputRectImg, COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    cv::split(inputRectImg,channels); //split the image into channels
    
    inputRectImg = channels[0]; //keep gray channel
    
    int rows = inputRectImg.rows;
    int cols = inputRectImg.cols;
    
    //count the sum of the pixl for the whole rect img
    int sum_pixl = 0;
    int sum_outer_pixl = 0;
    int counter_outer = 1;
    int counter_inner = 1;
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            uchar pixl = inputRectImg.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            
            if(i < 3 || j < 3 || i > (rows - 4) || j > (cols - 4)){
                sum_outer_pixl = sum_outer_pixl + pixl_int;
                counter_outer++;
                
            }
            
            sum_pixl = sum_pixl + pixl_int;
            counter_inner++;
            
            
        }
    }
    //count the average of the pixels
    int ave_pixl = sum_pixl/counter_inner;
    int ave_outer_pixl = sum_outer_pixl/counter_outer;
    
    NSLog(@"ImagePrePro: all: %u",ave_pixl);
    NSLog(@"ImagePrePro: out: %u",ave_outer_pixl);
    
    
    if(ave_pixl <= ave_outer_pixl){
        
        return 1;// normal i.e. white paper black words
    }
    if(ave_pixl > ave_outer_pixl){
        return 0;// black paper white words
    }
    else{
        return 1;//test mode
    }
    
}

@end