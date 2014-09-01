//
//  TextDetector.mm
//  TestGray
//
//  Created by CharlieGao on 7/01/14.
//  Copyright (c) 2014 Edible Innovations LLC. All rights reserved.
//

#import "TextDetector2.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"

using namespace cv;
using namespace std;

@implementation TextDetector2

-(Mat)findTextArea: (UIImage*)inputImage{
    
    NSLog(@"TextDetector: Called!");
    
    Mat inputMat = [inputImage CVMat];
    //NSMutableArray *imgUIArray = [[NSMutableArray alloc] init];;
    inputMat = [self findContour:inputMat:inputMat];
    
    return inputMat;
}


//-----------find contour

typedef vector<vector<cv::Point> > TContours;//global
-(Mat)findContour:(Mat)inputImg :(Mat)orgImage{
    
    cvtColor( inputImg, inputImg, COLOR_BGR2GRAY );
    
    //cv::fastNlMeansDenoising(inputImg, inputImg, 3.0f, 7, 21);
    
    double high_thres = threshold( inputImg, inputImg, 0, 255, THRESH_BINARY+THRESH_OTSU );
    
    Mat canny_output;
    NSMutableArray *UIRects = [[NSMutableArray alloc] init];
    vector<Vec4i> hierarchy;
    
    /// Detect edges using canny
    Canny( inputImg, canny_output, high_thres*0.5, high_thres, 3 );
    
    //typedef cv::vector<cv::vector<cv::Point> > TContours;
    TContours contours;
    
    
    /// Find contours
    findContours( canny_output, contours, hierarchy, RETR_LIST, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    
    Mat drawing ;//= Mat::zeros( canny_output.size(), CV_8UC3 );
    drawing = orgImage;
    
    /// Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect(contours.size());
    vector<Point2f>center(contours.size());
    vector<float>radius(contours.size());
    
    int counter_noise = 0;
    int counter_tempRect = 0;
    for( int i = 0; i < contours.size();i++)
    {
        drawContours( drawing, contours, i, Scalar(255,0,0), 1, 8, hierarchy, 0, cv::Point() );
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        cv::Rect tempRect = boundingRect(Mat(contours_poly[i]));
        
        if(tempRect.width < 2 || tempRect.height < 2){
            counter_noise ++;
            
        }else{
            
            boundRect[counter_tempRect] = tempRect;
            counter_tempRect++;
        }
    }
    
    NSLog(@"TextDetector: noise counter: %d",counter_noise);
    
    if(counter_noise < 1500){
        //---remove insider rects
        vector<cv::Rect> outRect;
        outRect = [self removeInsider:boundRect];
        
        //----merge near
        vector<cv::Rect> merged_rects;
        merged_rects = [self mergeNeighbors:outRect];
        //----merge overlap
        vector<cv::Rect> sigle_rects;
        sigle_rects = [self removeOverlape:merged_rects];
        //----sort vectors
        std::sort(sigle_rects.begin(), sigle_rects.end(), compareLoc);
        
        for(int i = 0; i< sigle_rects.size(); i++){
            if(sigle_rects[i].width > 10 && sigle_rects[i].height > 15 )
            {
                Mat tmpMat;
                
                int x = max(sigle_rects[i].x-3,0);
                int y = max(sigle_rects[i].y-3,0);
                int w = sigle_rects[i].width;
                int h = sigle_rects[i].height;
                
                if( x+w+6 > orgImage.cols){
                    w = w;
                }
                else {
                    w = w + 6;
                }
                
                if( y+h+6 > orgImage.rows){
                    h = h;
                }
                else {
                    h = h + 6;
                }
                
                cv::Rect tempRect = cv::Rect(x,y,w,h);
                orgImage(tempRect).copyTo(tmpMat); //resized rect
                
                [UIRects addObject:[UIImage imageWithCVMat:tmpMat]];
                
                rectangle(drawing, tempRect.tl(), tempRect.br(), Scalar(0,0,255), 2, 8, 0 ); // draw rectangles
            }
            else{
                //NSLog(@"nothing to draw: %d",i);
            }
        }

    }
    //return UIRects;
    return drawing;
}

//Comparison function for std::sort
//Sort regions y-axis desc. and x-axis asce.
bool compareLoc(const cv::Rect &a,const cv::Rect &b){
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
        cv::Rect rect0 = rects[i]; //temp Rect
        
        if(rect0.height==0 || rect0.width == 0){
            break;
        }
        
        if(i == 0){
            newRects[0] = rect0;
        }
        
        for(int j = 0; j< rects.size(); j++){
            if(i != j){
                cv::Rect intersection = rect0 & rects[j];
                
                if(intersection == rect0 && (rect0.area()!=rects[j].area()))//current is insider
                {
                    flag += 1;
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
        
        if(rect0.height == 0 || rect0.width == 0){
            break;
        }
        
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
        
        if(tempRect.height == 0 || tempRect.width == 0){
            break;
        }
        
        for(int index_in = 0;index_in < rects.size();index_in++){
            
            if(index == 0){//first rect
                
                newRects[0] = rects[0];
            }
            
            cv::Point pl0 = rects[index].tl();
            cv::Point br0 = rects[index].br();
            cv::Point pl1 = rects[index_in].tl();
            //cv::Point br1 = rects[index_in].br();
            int distance_x = abs(br0.x-pl1.x);
            int distance_mid = abs(pl0.y+rects[index].height/2 - (pl1.y+rects[index_in].height/2));
            int distance_threshold = (rects[index].height)/2;
            
            int diff_height = abs(rects[index].height - rects[index_in].height);
            
            if( distance_x < 35 && distance_mid < distance_threshold
               && index != index_in && diff_height < (distance_threshold*1.5)){
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