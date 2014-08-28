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
    vector<cv::Rect> boundRect;
    vector<Point2f>center(contours.size() );
    vector<float>radius(contours.size() );
    
    int counter_noise = 0;
    int counter_tempRect = 0;
    for( int i = 0; i < contours.size();i++)
    {
        drawContours( drawing, contours, i, Scalar(255,0,0), 1, 8, hierarchy, 0, cv::Point() );
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        cv::Rect tempRect = boundingRect(Mat(contours_poly[i]));
        
        int rectArea = tempRect.area();
        if(rectArea<30)
        {
            counter_noise ++;
        }
        else
        {
            boundRect.push_back(tempRect);
            counter_tempRect++;
        }
    }
    
    NSLog(@"TextDetector: noise counter: %d",counter_noise);
    
    if(counter_noise < 1500){
        //---remove insider rects
        vector<cv::Rect> outRect;
        outRect = [self removeInsider:boundRect];
        
        //if the image is empty after this, do something;
        if(outRect.size()==0)
        {
        }
        
        //----merge near
        vector<cv::Rect> merged_rects;
        merged_rects = [self mergeNeighbors:outRect];
        
        if(merged_rects.size()==0)
        {
        }
        
        //----merge overlap
        vector<cv::Rect> single_rects;
        single_rects = [self removeOverlape:merged_rects];
        
        if(single_rects.size()==0)
        {
        }

        //----sort vectors
        std::sort(single_rects.begin(), single_rects.end(), compareLoc);
        
        for(int i = 0; i< single_rects.size(); i++){
            if(single_rects[i].width > 10 && single_rects[i].height > 15 )
            {
                Mat tmpMat;
                
                int x = max(single_rects[i].x-3,0);
                int y = max(single_rects[i].y-3,0);
                int w = single_rects[i].width;
                int h = single_rects[i].height;
                
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
                
                rectangle(drawing, tempRect.tl(), tempRect.br(), Scalar(0,0,255), 1, 8, 0 ); // draw rectangles
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
    vector<cv::Rect> newRects;
    bool flag = false;          //true if the current rect is inside the other
    
    int rectSize = int(rects.size());
    if(rectSize==0)
    {
        //if the rects is empty
        return newRects;
    }
    
    for( int i = 0; i< rectSize; i++ )
    {
        flag = false;
        cv::Rect tempRect = rects[i]; //temp Rect
        
        for(int j = i+1; j< rectSize; j++)
        {
            cv::Rect intersection = tempRect & rects[j];
            
            if(intersection == tempRect && (tempRect.area()!=rects[j].area()))//current is insider
            {
                //the current shape is inside the other one, don't push in
                flag = true;
            }
            else if(intersection == rects[j] && (tempRect.area()!=rects[j].area()))
            {
                //the current shape include the scanned one, delete that one
                rects.erase(rects.begin()+j);
                //if the one is deleted, go back one step, and the size decrease
                j--;
                rectSize--;
            }
        }
        //only if the current shape is independent, that it will be put into the result vector
        if(!flag)
        {
            newRects.push_back(tempRect);
        }
    }
    
    return newRects;
}

-(vector<cv::Rect>)removeOverlape:(vector<cv::Rect>)rects{
    vector<cv::Rect> newRects;
    bool flag = false;          //true if the current rect is inside the other
    
    int rectSize = int(rects.size());
    if(rectSize==0)
    {
        //if the rects is empty
        return newRects;
    }
    
    for( int i = 0; i< rectSize; i++ )
    {
        flag = false;
        cv::Rect tempRect = rects[i]; //temp Rect
        
        for(int j = i+1; j< rectSize; j++)
        {
            cv::Rect intersection = tempRect & rects[j];
            
            if(intersection.area() > 0)//current is insider
            {
                rects[j] |= tempRect;
                flag = true;
            }
        }
        //only if the current shape is independent, that it will be put into the result vector
        if(!flag)
        {
            newRects.push_back(tempRect);
        }
    }
    
    return newRects;
    
}


-(vector<cv::Rect>)mergeNeighbors:(vector<cv::Rect>)rects
{
    vector<cv::Rect> newRects;
    bool flag = false;          //true if the current rect is inside the other
    
    int rectSize = int(rects.size());
    if(rectSize==0)
    {
        //if the rects is empty
        return newRects;
    }
    
    for( int i = 0; i< rectSize; i++ )
    {
        //flag indicates the current
        flag = false;
        cv::Rect tempRect = rects[i];
        
        for(int j = i+1; j< rectSize; j++)
        {
            cv::Point pl0 = rects[i].tl();
            cv::Point br0 = rects[i].br();
            cv::Point pl1 = rects[j].tl();
            //cv::Point br1 = rects[index_in].br();
            int distance_x = abs(br0.x-pl1.x);
            int distance_mid = abs(pl0.y+rects[i].height/2 - (pl1.y+rects[j].height/2));
            int distance_threshold = (rects[i].height)/2;
            
            int diff_height = abs(rects[i].height - rects[j].height);
            
            if( distance_x < 35 && distance_mid < distance_threshold
               && i != j && diff_height < (distance_threshold*1.5))
            {
                //if two rects are close, then merge the insider to the current,
                //delete the merged one,
                tempRect |= rects[j];
                rects.erase(rects.begin()+j);
                j --;
                rectSize --;
            }
        }
        //only if the current shape is independent, that it will be put into the result vector
        newRects.push_back(tempRect);
    }
    return newRects;
}


//-----------/find contour


@end