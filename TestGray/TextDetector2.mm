//
//  TextDetector.mm
//  TestGray
//
//  Created by CharlieGao on 7/01/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "TextDetector2.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"

using namespace cv;
using namespace std;

@implementation TextDetector2



-(cv::Mat)findTextArea: (cv::Mat)inputImage{
    
    NSLog(@"TextDetector: Called!");
    
    //cv::Mat inputMat = [inputImage CVMat];

    
    NSMutableArray *imgUIArray;
    //imgUIArray = [self findContour:inputImage:inputImage];
   // NSArray *imgArray = [NSArray arrayWithArray:imgUIArray]; // output
    
   // UIImage* testUIImage = [imgUIArray objectAtIndex:0];
    //inputImage = [testUIImage CVMat];
    inputImage = [self findContour:inputImage original:inputImage];
    
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
    int dilation_elem = 1;
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

//------------/Basic method


//-------/Remove Back ground version1



-(cv::Mat)removeBackground:(cv::Mat)inputImage{
    
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    cv::GaussianBlur(inputImage, inputImage, size, 0.5);
    cv::threshold(inputImage, inputImage, 0,255, cv::THRESH_TRUNC|cv::THRESH_OTSU);
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    
    return inputImage;
    
}

//-------/Remove Back ground version1


//-----------find contour

typedef cv::vector<cv::vector<cv::Point> > TContours;//global
-(cv::Mat)findContour:(cv::Mat)inputImg original:(cv::Mat)orgImage{
    
    cv::cvtColor( inputImg, inputImg, CV_BGR2GRAY );

    double high_thres = cv::threshold( inputImg, inputImg, 0, 255, CV_THRESH_BINARY+CV_THRESH_OTSU );
    
    cv::Mat canny_output;
    cv::vector<cv::Vec4i> hierarchy;
    
    /// Detect edges using canny
    Canny( inputImg, canny_output, high_thres*0.5, high_thres, 3 );
    
    //typedef cv::vector<cv::vector<cv::Point> > TContours;
    TContours contours;
    
    
    /// Find contours
    findContours( canny_output, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    
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
    
    std::sort(sigle_rects.begin(), sigle_rects.end(), compareLoc);
    
    
    //---draw rects
    NSMutableArray *UIRects = [[NSMutableArray alloc] init];
    for(int i = 0; i< sigle_rects.size(); i++){
        if(sigle_rects[i].tl().x > 0 && sigle_rects[i].tl().y > 0)
        {//skip null
            rectangle(drawing, sigle_rects[i].tl(), sigle_rects[i].br(), Scalar(255,255,255), 1, 8, 0 );
            
            //convert to mat pointer and stored in NSarray
            cv::Mat tmpMat;
            //cv::Rect tempRect = cv::Rect(sigle_rects[i].x,sigle_rects[i].y,sigle_rects[i].width,sigle_rects[i].height);
            //orgImage(tempRect).copyTo(tmpMat); //resized rect
            
            //[UIRects addObject:[UIImage imageWithCVMat:tmpMat]];
            
        }
        else{
            //NSLog(@"nothing to draw: %d",i);
        }
    }
    
    return drawing;
    
    
}

//Comparison function for std::sort
//Sort regions y-axis desc. and x-axis asce.
bool compareLoc(const cv::Rect &a,const cv::Rect &b)
{
    if (a.y < b.y) return true;
    else if (a.y == b.y)
    {
        if(a.x < b.x) return true;
        else return false;
    }
    else return false;
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
            
            cv::Point pl0 = rects[index].tl();
            cv::Point br0 = tempRect.br();
            cv::Point pl1 = rects[index_in].tl();
            //cv::Point br1 = rects[index_in].br();
            int distance_x = abs(br0.x-pl1.x);
            int distance_y = abs(pl0.y-pl1.y);
            int distance_mid = abs(pl0.y+rects[index].height/2 - (pl1.y+rects[index_in].height/2));
            
            if( distance_x <40 && distance_mid < (rects[index].height/2-3) && index != index_in)
               //(rects[index].width/1.5) || distance_x < (rects[index_in].width/1.5) )
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