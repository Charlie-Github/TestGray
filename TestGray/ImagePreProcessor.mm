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



-(Mat)processImage: (Mat)inputImage{
    
    NSLog(@"ImagePrePro: Called!");
    
    Mat output;
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
        cvtColor(inputImage, inputImage, COLOR_BGRA2BGR);
        
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

-(Mat)toGrayMat:(UIImage *) inputImage{
    
    Mat matImage = [inputImage CVGrayscaleMat];
    return matImage;
}

-(Mat)erode:(Mat)img{
    
    int erosion_elem = 2;
    int erosion_size = 1;
    Mat erosion_dst;
    int erosion_type;
    if( erosion_elem == 0 ){ erosion_type = MORPH_RECT; }
    //else if( erosion_elem == 1 ){ erosion_type = MORPH_CROSS; }
    else { erosion_type = MORPH_ELLIPSE; }
    
    Mat element = getStructuringElement( erosion_type,
                                            cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                            cv::Point( erosion_size, erosion_size ) );
    /// Apply the erosion operation
    erode( img, erosion_dst, element );
    return erosion_dst;
    
}


-(Mat)dilate:(Mat)img{
    
    Mat dilation_dst;
    int dilation_type;
    int dilation_elem = 1;
    int dilation_size = 1;
    
    if( dilation_elem == 0 ){ dilation_type = MORPH_RECT; }
    //else { dilation_type = MORPH_CROSS; }
    else { dilation_type = MORPH_ELLIPSE; }
    
    Mat element = getStructuringElement( dilation_type,
                                            cv::Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                            cv::Point( dilation_size, dilation_size ) );
    /// Apply the dilation operation
    dilate( img, dilation_dst, element );
    
    return dilation_dst;
    
}



-(Mat)gaussianBlur:(Mat)inputImage :(int)h :(int)w{
    
    Mat output;
    cv::Size size;
	size.height = h;
	size.width = w;
    GaussianBlur(inputImage, output, size, 0.8);
    return output;
    
}

-(Mat)laplacian:(Mat)inputImage{
    
    Mat output;
    Mat kernel = (Mat_<float>(3, 3) << 0, -1, 0, -1, 4, -1, 0, -1, 0); //Laplacian operator
    filter2D(inputImage, output, output.depth(), kernel);
    return output;
    
}

-(Mat)sharpen:(Mat)inputImage{
    Mat output;
    GaussianBlur(inputImage, output, cv::Size(0, 0), 10);
    addWeighted(inputImage, 1.5, output, -0.5, 0, output);
    return output;
}



-(Mat)increaseContrast:(Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    
    
    vector<Mat> channels;
    
    Mat img_hist_equalized;
    
    cvtColor(inputMat, img_hist_equalized, COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    
    split(img_hist_equalized,channels); //split the image into channels
    
    equalizeHist(channels[0], channels[0]); //equalize histogram on the 1st channel (Y)
    
    merge(channels,img_hist_equalized); //merge 3 channels including the modified 1st channel into one image
    
    cvtColor(img_hist_equalized, img_hist_equalized, COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_hist_equalized;
    
}
//------------/Basic method


//------Threshold method

-(Mat)adaptiveThreshold:(Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    //the first channel of YCrCb is for grayscale representation, feeding into adaptiveThrenshold function whose input is sigle channel
    
    vector<Mat> channels;
    
    Mat img_threshold;
    cvtColor(inputMat, img_threshold, COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    split(img_threshold,channels); //split the image into channels
    
    
    //cv::fastNlMeansDenoising(channels[0], channels[0], 3.0f, 7, 35);
    
    //--Simple threshold, removing little noisy
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    GaussianBlur(channels[0], channels[0], size, 0.5);
    threshold(channels[0], channels[0], 0,255, THRESH_TRUNC | THRESH_OTSU);
    
    //--Simple end here
    
    adaptiveThreshold(channels[0], channels[0], 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY,11, 2);
    merge(channels,img_threshold); //merge 3 channels including the modified 1st channel into one image
    cvtColor(img_threshold, img_threshold, COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_threshold;
}


-(Mat)adaptiveThresholdBlack:(Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    //the first channel of YCrCb is for grayscale representation, feeding into adaptiveThrenshold function whose input is sigle channel
    
    vector<Mat> channels;
    
    Mat img_threshold;
    cvtColor(inputMat, img_threshold, COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    split(img_threshold,channels); //split the image into channels
    
    
    //cv::fastNlMeansDenoising(channels[0], channels[0], 3.0f, 7, 11);
    
    //--Simple threshold, removing little noisy
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    GaussianBlur(channels[0], channels[0], size, 0.5);
    //reverse color
    
    bitwise_not(channels[0], channels[0]);
    
    threshold(channels[0], channels[0], 0,255, THRESH_TRUNC | THRESH_OTSU);
    
    //--Simple ends here
    
    adaptiveThreshold(channels[0], channels[0], 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY,11, 2);
    merge(channels,img_threshold); //merge 3 channels including the modified 1st channel into one image
    cvtColor(img_threshold, img_threshold, COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_threshold;
    
}

//------/Threshold method


-(int)checkBackground2:(Mat)inputRectImg{
    
    vector<Mat> channels;
    cvtColor(inputRectImg, inputRectImg, COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    split(inputRectImg,channels); //split the image into channels
    
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