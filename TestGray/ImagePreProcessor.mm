//
//  ImagePreProcessor.m
//  TestGray
//
//  Created by CharlieGao on 6/27/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ImagePreProcessor.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"


@implementation ImagePreProcessor



-(cv::Mat)processImage: (cv::Mat)inputImage{
    
    NSLog(@"PrePro: processImage called!");
    
    cv::Mat output;
    int backGround =0;
    //backGround = [self checkBackground:inputImage];
    if (backGround == 0) {
        NSLog(@"Prepro: Black backgroud");
        
        inputImage = [self increaseContrast:inputImage];
        
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
        
        inputImage = [self removeBackgroundBlack:inputImage];
        
        
        
    }
    else if(backGround == 1){
        NSLog(@"Prepro: Light Dark");
        
        cv::cvtColor(inputImage, inputImage, cv::COLOR_BGRA2BGR);
        inputImage = [self adaptiveThreshold:inputImage];
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
        
    }
    else if(backGround == 2 ){
        NSLog(@"Prepro: White words");
        
        inputImage = [self removeBackgroundWhite:inputImage];
        inputImage = [self increaseContrast:inputImage];
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
    }
    else{
        NSLog(@"Prepro: good catch");
    }
    
    copyMakeBorder( inputImage, inputImage, 10, 10, 10, 10, cv::BORDER_REPLICATE, 0 );//add border
    
    return inputImage;
}

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
    else if( erosion_elem == 1 ){ erosion_type = cv::MORPH_CROSS; }
    else if( erosion_elem == 2) { erosion_type = cv::MORPH_ELLIPSE; }
        
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
    int dilation_elem = 0;
    int dilation_size = 1;
    
    if( dilation_elem == 0 ){ dilation_type = cv::MORPH_RECT; }
    else if( dilation_elem == 1 ){ dilation_type = cv::MORPH_CROSS; }
    else if( dilation_elem == 2) { dilation_type = cv::MORPH_ELLIPSE; }
    
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
    
    
    cv::vector<cv::Mat> channels;
    
    cv::Mat img_hist_equalized;
    
    cv::cvtColor(inputMat, img_hist_equalized, CV_BGR2YCrCb); //change the color image from BGR to YCrCb format
    
    cv::split(img_hist_equalized,channels); //split the image into channels
    
    cv::equalizeHist(channels[0], channels[0]); //equalize histogram on the 1st channel (Y)
    
    cv::merge(channels,img_hist_equalized); //merge 3 channels including the modified 1st channel into one image
    
    cv::cvtColor(img_hist_equalized, img_hist_equalized, CV_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_hist_equalized;
    
}


-(cv::Mat)adaptiveThreshold:(cv::Mat)inputMat{
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    //the first channel of YCrCb is for grayscale representation, feeding into adaptiveThrenshold function whose input is sigle channel
    

    cv::vector<cv::Mat> channels;
    
    cv::Mat img_threshold;
    
    cv::cvtColor(inputMat, img_threshold, CV_BGR2YCrCb); //change the color image from BGR to YCrCb format
    
    cv::split(img_threshold,channels); //split the image into channels
    
    //add simple threshold removing little
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(channels[0], channels[0], size, 0.5);
    cv::threshold(channels[0], channels[0], 0,255, cv::THRESH_TRUNC | cv::THRESH_OTSU);
    
    //simple end here
    
    cv::adaptiveThreshold(channels[0], channels[0], 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY,11, 2);
    
    cv::merge(channels,img_threshold); //merge 3 channels including the modified 1st channel into one image
    
    cv::cvtColor(img_threshold, img_threshold, CV_YCrCb2BGR); //change the color image from YCrCb to BGR format
    
    return img_threshold;

}


-(cv::Mat)adaptiveThresholdLight:(cv::Mat)inputMat{
    //currently same as adaptiveThreshold()
    //input mat is in BGR format
    //ouput mat is in BGR format
    //the function converts BGR into YCrCb format, and then takes care of the first channel of it.
    //the first channel of YCrCb is for grayscale representation, feeding into adaptiveThrenshold function whose input is sigle channel
    
    cv::vector<cv::Mat> channels;
    
    cv::Mat img_threshold;
    
    cv::cvtColor(inputMat, img_threshold, CV_BGR2YCrCb); //change the color image from BGR to YCrCb format
    
    cv::split(img_threshold,channels); //split the image into channels
    
    //add simple threshold removing little
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(channels[0], channels[0], size, 0.5);
    cv::threshold(channels[0], channels[0], 0,255, cv::THRESH_TRUNC | cv::THRESH_OTSU);
    
    //simple end here
    
    cv::adaptiveThreshold(channels[0], channels[0], 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY,11, 2);
    
    cv::merge(channels,img_threshold); //merge 3 channels including the modified 1st channel into one image
    
    cv::cvtColor(img_threshold, img_threshold, CV_YCrCb2BGR); //change the color image from YCrCb to BGR format

    return img_threshold;
    
}


-(cv::Mat) fillContour: (cv::Mat)image {
    


    return image;
}



-(int)checkBackground:(cv::Mat )input
{
    
    
    cv::vector<cv::Mat> channels;
    
    cv::cvtColor(input, input, CV_BGR2YCrCb); //change the color image from BGR to YCrCb format
    
    cv::split(input,channels); //split the image into channels
    
    input = channels[0]; //keep gray image
    
    int rows = input.rows;
    int cols = input.cols;
    
    //count the sum of the pixl
    int sum_pixl = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            uchar pixl = input.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            sum_pixl = sum_pixl + pixl_int;
        }
    }
    //count the average of the pixel
    int ave_pixl = sum_pixl/(rows*cols);
    
    int pivot_pixl_xsmall = ave_pixl * 1/3;
    int pivot_pixl_small = ave_pixl * 2/3;
   
    int pivot_pixl_medium = ave_pixl* 1;
    
    int pivot_pixl_large = ave_pixl * 4/3;
    int pivot_pixl_xlarge = ave_pixl * 5/3;
    
    //count_white the nuber of pixl which value are bigger than average
    int count_xsmall = 0;
    int count_small = 0;
    int count_medium = 0;
    int count_large = 0;
    int count_xlarge = 0;
    int count_average = rows * cols / 5;
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            
            uchar pixl = input.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            
            if (pixl_int <= pivot_pixl_xsmall) {
                count_xsmall ++ ;
            }
            else if(pixl_int > pivot_pixl_xsmall && pixl_int < pivot_pixl_small){
                count_small ++ ;
            }
            else if(pixl_int > pivot_pixl_small && pixl_int < pivot_pixl_medium){
                count_medium ++ ;
            }
            else if(pixl_int > pivot_pixl_medium && pixl_int < pivot_pixl_large){
                count_medium ++;
            }
            else if(pixl_int > pivot_pixl_large && pixl_int < pivot_pixl_xlarge){
                count_large ++;
            }
            else if(pixl_int > pivot_pixl_xlarge) {
                count_xlarge ++;
            }
            
            
        }
    }
    
    if (count_xsmall >= count_large  + count_medium) {
        return 0;// too dark
    }
    else if(count_large >= count_small * 2 + count_medium) {
        NSLog(@"large: %d", count_large);
        NSLog(@"small: %d", count_medium);
        return 1;// too light
    }
    else if (count_medium > count_small && count_medium < count_large){
        return 2;// medium
    }else
        return 3;
}
    



-(cv::Mat)removeBackgroundBlack:(cv::Mat)inputImage{
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    cv::threshold(inputImage, inputImage, 125,255, cv::THRESH_BINARY_INV);
    //cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    
    return inputImage;
    
}

-(cv::Mat)removeBackgroundWhite:(cv::Mat)inputImage{
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    cv::threshold(inputImage, inputImage, 190,255, cv::THRESH_TRUNC);
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    
    return inputImage;
    
}

//-------below is remove back ground version 2  stable version



-(cv::Mat)removeBackground2:(cv::Mat) inputMat
{
    cv::Mat Img,res;
    
    cv::cvtColor(inputMat, Img, cv::COLOR_BGRA2GRAY);
    Img.convertTo(Img, CV_8UC4);
    Img.convertTo(Img,CV_32FC1,1.0/255.0);
   
    res = [self CalcBlockMeanVariance:Img:21];
    res=1.0-res;
    res=Img+res;
    
    cv::threshold(res,res,0.80,1,cv::THRESH_BINARY );
    
    
    res.convertTo(res, CV_8UC4,255);
    cv::cvtColor(res, res, cv::COLOR_GRAY2BGR);
    return res;
}

-(cv::Mat)CalcBlockMeanVariance:(cv::Mat) Img : (float) blockSide
// blockSide - the parameter (set greater for larger font on image)
{
    cv::Mat I;
    
    
    Img.convertTo(I,CV_32FC1);
    cv::Mat Res;
    Res=cv::Mat::zeros(Img.rows/blockSide,Img.cols/blockSide,CV_32FC1);
    cv::Mat inpaintmask;
    cv::Mat patch;
    cv::Mat smallImg;
    
    cv::Scalar m,s;
    
    
    for(int i=0;i<Img.rows-blockSide;i+=blockSide)
    {
        for (int j=0;j<Img.cols-blockSide;j+=blockSide)
        {
            patch=I(cv::Range(i,i+blockSide+1),cv::Range(j,j+blockSide+1));
            cv::meanStdDev(patch,m,s);
            if(s[0]>0.01) // Thresholding parameter (set smaller for lower contrast image)
            {
                Res.at<float>(i/blockSide,j/blockSide)=m[0];
            }else
            {
                Res.at<float>(i/blockSide,j/blockSide)=0;
            }
        }
    }
    
    cv::resize(I,smallImg,Res.size());
    
    cv::threshold(Res,inpaintmask,0.02,1.0,cv::THRESH_BINARY);
    
    cv::Mat inpainted;
    smallImg.convertTo(smallImg,CV_8UC1,255);
    
    inpaintmask.convertTo(inpaintmask,CV_8UC1);
    
    cv::inpaint(smallImg, inpaintmask, inpainted, 5, cv::INPAINT_TELEA);
    
    cv::resize(inpainted,Res,Img.size());
    Res.convertTo(Res,CV_32FC1,1.0/255.0);
    return Res;
}




//-------/remove back ground v2


@end