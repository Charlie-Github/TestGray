//
//  ImagePreProcessor.m
//
//
//  Created by CharlieGao on 6/30/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
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
        
        //inputImage = [self increaseContrast:inputImage];
        //inputImage = [self erode:inputImage];
        //inputImage = [self dilate:inputImage];
        /*
         inputImage = [self removeBackgroundBlack:inputImage];
         inputImage = [self erode:inputImage];
         inputImage = [self dilate:inputImage];
         */
        inputImage = [self adaptiveThresholdBlack:inputImage];
        inputImage = [self erode:inputImage];
        inputImage = [self dilate:inputImage];
        
    }
    else if(backGround == 1){
        NSLog(@"ImagePrePro: Normal Image");
        
        //inputImage = [self increaseContrast:inputImage];
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
        //       inputImage = [self adaptiveThreshold:inputImage];
        //       inputImage = [self erode:inputImage];
        //       inputImage = [self dilate:inputImage];
        NSMutableArray *imgUIArray;
        imgUIArray = [self findContour:inputImage:inputImage];
        UIImage* testUIImage = [imgUIArray objectAtIndex:1];
        
        inputImage = [testUIImage CVMat];
        
    }
    
    return inputImage;}



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
    else { dilation_type = cv::MORPH_CROSS; }
    //else if( dilation_elem == 2) { dilation_type = cv::MORPH_ELLIPSE; }
    
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


-(int)checkBackground:(cv::Mat )input{
    //this function check image background is black or white
    
    std::vector<cv::Mat> channels;
    cv::cvtColor(input, input, COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
    cv::split(input,channels); //split the image into channels
    
    input = channels[0]; //keep gray channel
    
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
    
    if (count_xsmall >= count_large + count_xlarge + count_medium) {
        return 0;// Black background
    }
    else{
        return 1;// Normal light
    }
}


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
    
    for (int i = 0; i < rows; i = i+2) {
        for (int j = 0; j < cols; j = j+2) {
            uchar pixl = inputRectImg.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            
            if(i < 2 || j < 2 ){
                sum_outer_pixl = sum_outer_pixl + pixl_int;
            }
            
            sum_pixl = sum_pixl + pixl_int;
            
        }
    }
    //count the average of the pixels
    int ave_pixl = sum_pixl/(rows*cols);
    int ave_outer_pixl = sum_outer_pixl/(2*(rows+cols));
    //NSLog(@"ImagePrePro: all: %d",ave_pixl);
    //NSLog(@"ImagePrePro: out: %d",ave_outer_pixl);
    
    
    
    
    if(ave_pixl <= ave_outer_pixl){
        
        return 1;// normal i.e. white paper black words
    }
    if(ave_pixl > ave_outer_pixl){
        return 0;// black paper white words
    }
    else{
        return 2;//test mode
    }
    
}



-(cv::Mat)removeBackgroundBlack:(cv::Mat)inputImage{
    //This function removes background for images with black background.
    //Reverse color function is adopt in this section
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    cv::threshold(inputImage, inputImage, 100,255, cv::THRESH_BINARY_INV);
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    
    return inputImage;
    
}

-(cv::Mat)removeBackgroundWhite:(cv::Mat)inputImage{
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    cv::threshold(inputImage, inputImage, 220,255, cv::THRESH_TRUNC);
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    
    return inputImage;
    
}

-(cv::Mat)removeBackground:(cv::Mat)inputImage{
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    cv::threshold(inputImage, inputImage, 0,255, cv::THRESH_TRUNC);
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    
    return inputImage;
    
}

//-------/Remove Back ground version1

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

//-----------find contour

typedef vector<vector<cv::Point> > TContours;
-(NSMutableArray*)findContour:(cv::Mat)inputImage :(cv::Mat)orgImage{
    
    cv::cvtColor( inputImage, inputImage, COLOR_BGR2GRAY );
    
    double high_thres = cv::threshold( inputImage, inputImage, 0, 255, THRESH_BINARY+THRESH_OTSU );
    
    cv::Mat canny_output;
    //cv::vector<cv::vector<Point> > contours;
    vector<cv::Vec4i> hierarchy;
    
    /// Detect edges using canny
    Canny( inputImage, canny_output, high_thres/2, high_thres, 3 );
    
    //typedef cv::vector<cv::vector<cv::Point> > TContours;
    TContours contours;
    
    
    /// Find contours
    findContours( canny_output, contours, hierarchy, RETR_LIST, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    
    
    /// Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect( contours.size() );
    vector<Point2f>center( contours.size() );
    vector<float>radius( contours.size() );
    
    
    for( int i = 0; i < contours.size(); i++ )
    {
        drawContours( drawing, contours, i, Scalar(255,0,0), 1, 8, hierarchy, 0, cv::Point() );
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        boundRect[i] = boundingRect( Mat(contours_poly[i]) );
    }
    
    
    //---remove insider rects
    vector<cv::Rect> outRect;
    outRect = [self removeInsider:boundRect];
    
    
    //----merge near
    vector<cv::Rect> merged_rects;
    merged_rects = [self mergeNeighbors:outRect];
    
    
    //----merge overlap
    vector<cv::Rect> sigle_rects;
    sigle_rects = [self removeOverlape:merged_rects];
    
    
    
    //---draw rects
    NSMutableArray *UIRects = [[NSMutableArray alloc] init];
    for(int i = 0; i< sigle_rects.size(); i++){
        if(sigle_rects[i].tl().x > 0 && sigle_rects[i].tl().y > 0)
        {//skip null
            //rectangle(drawing, sigle_rects[i].tl(), sigle_rects[i].br(), Scalar(255,255,255), 1, 8, 0 );
            
            //convert to mat pointer and stored in NSarray
            cv::Mat tmpMat;
            
            orgImage(sigle_rects[i]).copyTo(tmpMat);
            
            [UIRects addObject:[UIImage imageWithCVMat:tmpMat]];
            
        }
        else{
            //NSLog(@"nothing to draw: %d",i);
        }
    }
    
    return UIRects;
    
    
}


-(vector<cv::Rect>)removeInsider:(vector<cv::Rect>)rects{
    
    cv::Rect bigRect; //temp
    vector<cv::Rect> newRects(rects.size());
    int newIndex = 0;
    int flag;
    
    for( int i = 0; i< rects.size(); i++ )
    {
        flag = 0;
        cv::Rect rect0 = rects[i]; //temp
        
        if(i == 0){
            newRects[0] = rect0;
        }
        
        for(int j = 0; j< rects.size(); j++){
            if(i != j){
                cv::Rect intersection = rect0 & rects[j];
                
                if(intersection == rect0 && (rect0.area()!=rects[j].area()))//current is insider
                {
                    flag += 1;
                    //NSLog(@"j : %d",j);
                    
                }
                else{
                    //if current rect is not a insider, then add it to newRect
                    flag += 0;
                    
                }
            }
        }
        
        if(flag == 0){
            newRects[newIndex] = rect0;
            newIndex ++;
        }
        
    }
    
    return newRects;
}

-(vector<cv::Rect>)removeOverlape:(vector<cv::Rect>)rects{
    
    cv::Rect bigRect; //temp
    vector<cv::Rect> newRects(rects.size());
    int newIndex = 0;
    int flag;
    
    for( int i = 0; i< rects.size(); i++ )
    {
        flag = 0;
        cv::Rect rect0 = rects[i]; //temp
        
        if(i == 0){
            newRects[0] = rect0;
        }
        
        for(int j = i+1; j< rects.size(); j++){
            if(i != j){
                cv::Rect intersection = rect0 & rects[j];
                
                if(intersection.area() > 0 )//current is overlaped with some
                {
                    flag += 1;
                    rects[j] |= rect0;
                    
                    
                }
                else{
                    flag += 0;
                    
                }
            }
        }
        if(flag == 0){
            //NSLog(@"newIndex: %d",newIndex);
            newRects[newIndex] = rect0;
            newIndex ++;
        }
    }
    
    return newRects;
    
    
}

-(vector<cv::Rect>)mergeNeighbors:(vector<cv::Rect>)rects{
    
    int index = 0;
    int newIndex = 0;
    int flag = 0;
    vector<cv::Rect> newRects(rects.size());
    
    for(index= 0; index<rects.size();index++){
        
        flag = 0;
        cv::Rect tempRect = rects[index];
        
        for(int index_in=0;index_in<rects.size();index_in++){
            
            if(index == 0){//first rect
                
                newRects[0] = rects[0];
            }
            
            //cv::Point pl0 = rects[index].tl();
            cv::Point br0 = tempRect.br();
            cv::Point pl1 = rects[index_in].tl();
            //cv::Point br1 = rects[index_in].br();
            int distance_x = abs(br0.x-pl1.x);
            //int distance_y = abs(br0.y-pl1.y);
            
            
            if( (distance_x < 8) && index != index_in)
            {
                //if two rects are close, then merge the insider to the current,
                // counter dose not increas
                
                tempRect |= rects[index_in];
                flag += 1;
                
            }
            else{
                //if current rect is far from the second rect, then count ++
                flag +=0;
                
            }
            
        }
        //NSLog(@"newIndex: %d",newIndex);
        newRects[newIndex] = tempRect;
        newIndex++;
        
    }
    return newRects;
}

//-----------/find contour

@end