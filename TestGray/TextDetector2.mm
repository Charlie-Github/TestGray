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

-(Mat)findTextArea: (UIImage*)inputImage
{
    
    NSLog(@"TextDetector: Called!");
    
    Mat inputMat = [inputImage CVMat];
    inputMat = [self findContour:inputMat:inputMat];
    
    return inputMat;
}


//-----------find contour

typedef vector<vector<cv::Point> > TContours;//global
-(Mat)findContour:(Mat)inputImg :(Mat)orgImage
{
    
    cvtColor( inputImg, inputImg, COLOR_BGR2GRAY );
    Mat drawing ;
    drawing = orgImage;
    
    int wholeArea = drawing.size().height * drawing.size().width;
    
    Mat canny_output;
    Mat input_th;
    NSMutableArray *UIRects = [[NSMutableArray alloc] init];
    vector<Vec4i> hierarchy;
    
    /// threshold with Otsu
    Mat temp;
    threshold(inputImg, input_th, 0, 255, THRESH_OTSU);
    
//    imwrite("/Users/canoee/Documents/BlueCheese/code/TestGray/input_th.png", input_th);
    
    TContours contours;

    /// Find contours
    findContours( input_th, contours, hierarchy, RETR_LIST, CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    /// Approximate contours to polygons + get bounding rects and circles
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect;
    vector<Point2f>center(contours.size() );
    vector<float>radius(contours.size() );
    
    for( int i = 0; i < contours.size();i++)
    {
        drawContours( drawing, contours, i, Scalar(255,0,0), 1, 8, hierarchy, 0, cv::Point() );
        approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
        cv::Rect tempRect = boundingRect(Mat(contours_poly[i]));
        double tempHeight = tempRect.height;
        double tempWidth = tempRect.width;
        double tempRatio = tempHeight/tempWidth;
        int tempArea = tempRect.area();
        bool flagNoise = false;                      //used to eleminate noisy points
        if(tempRatio>5||tempRatio<0.2)
        {
            flagNoise = true;
        }
        if(tempArea < wholeArea/3 && tempArea>wholeArea/10000 && !flagNoise)
        {
            boundRect.push_back(tempRect);
        }
    }
    
    //----merge near
    vector<cv::Rect> merged_rects;
    merged_rects = [self mergeNeighbors:boundRect];
    
    if(merged_rects.size()==0)
    {
        return drawing;
    }
    
    //---remove insider rects
    vector<cv::Rect> outRect;
    outRect = [self removeInsider:merged_rects];
    
    //if the image is empty after this, do something;
    if(outRect.size()==0)
    {
        return drawing;
    }
    
    //----sort vectors
    vector<cv::Rect> result_rects;
    result_rects = outRect;
    
    std::sort(result_rects.begin(), result_rects.end(), compareLoc);
    
    for(int i = 0; i< result_rects.size(); i++)
    {
        if(result_rects[i].width > 10 && result_rects[i].height > 15 )
        {
            Mat tmpMat;
            
            int x = max(result_rects[i].x-3,0);
            int y = max(result_rects[i].y-3,0);
            int w = result_rects[i].width;
            int h = result_rects[i].height;
            
            if( x+w+6 > orgImage.cols)
            {
                w = w;
            }
            else
            {
                w = w + 6;
            }
            
            if( y+h+6 > orgImage.rows)
            {
                h = h;
            }
            else
            {
                h = h + 6;
            }
            
            cv::Rect tempRect = cv::Rect(x,y,w,h);
            orgImage(tempRect).copyTo(tmpMat); //resized rect
            
            [UIRects addObject:[UIImage imageWithCVMat:tmpMat]];
            
            rectangle(drawing, tempRect.tl(), tempRect.br(), Scalar(0,0,255), 2, 8, 0 ); // draw rectangles
        }
    }    
    
    //return UIRects;
//    imwrite("/Users/canoee/Documents/BlueCheese/code/TestGray/drawing.png", drawing);
    return drawing;
}

//Comparison function for std::sort
//Sort regions y-axis desc. and x-axis asce.
bool compareLoc(const cv::Rect &a,const cv::Rect &b)
{
    if (a.y < b.y)
    {
        return true;
    }
    else if (a.y == b.y)
    {
        if(a.x < b.x)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }
}

-(vector<cv::Rect>)removeInsider:(vector<cv::Rect>)rects
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
        
        for(int j = 0; j< rectSize; j++)
        {
            //find the landmark points
            cv::Point tl0 = tempRect.tl();      //top left of first    THIS NEEDS TO BE UPDATED
            cv::Point br0 = tempRect.br();      //bot right of first   THIS NEEDS TO BE UPDATED
            cv::Point tl1 = rects[j].tl();      //top left of second
            cv::Point br1 = rects[j].br();      //bot right of second
            cv::Point c0;                       //center of first
            c0.x = (tl0.x+br0.x)/2;
            c0.y = (tl0.y+br0.y)/2;
            cv::Point c1;                       //center of second
            c1.x = (tl1.x+br1.x)/2;
            c1.y = (tl1.y+br1.y)/2;
            
            //find the distances between
            //need more thinking about the signs
            int dist_y_center = abs(c1.y - c0.y);   //distance between centers in y
            int dist_th = min(rects[j].height,tempRect.height)/2;           //threshold is set at half of mean height
            
            if(dist_y_center<dist_th)               //Do nothing for the words not on the same line
            {
                int diff_height = abs(tempRect.height - rects[j].height);       //difference of heights
                int dist_x_center = abs(c1.x - c0.x);        //distance between centers in x
                int dist_x = dist_x_center - (tempRect.width+rects[j].width)/2;    //the distance should be the center minus the half width sum.
                
                bool flag_x = false;                //used to determine the x directions
                bool flag_h = false;                //used to determine the height
                
                //determine the x direction
                if(dist_x < 50)                     //the number NEED to be changed maybe
                {
                    flag_x = true;
                }
                
                //the difference in height either smaller than the threshold,
                //or one include the other with higher threshold
                if(diff_height<dist_th
                   || (tl0.y<tl1.y&&br0.y>br1.y&&diff_height<dist_th*2.2)
                   ||  (tl0.y>tl1.y&&br0.y<br1.y&&diff_height<dist_th*2.2))
                {
                    flag_h = true;
                }
                
                if( flag_x && i != j && flag_h )
                {
                    //if two rects are close, then merge the insider to the current,
                    //delete the merged one,
                    tempRect |= rects[j];
                    rects.erase(rects.begin()+j);
                    j = -1;                             //whenever a merge is found, start from beginning
                    rectSize --;
                }
                else
                {
                    //Empty
                }
            }
        }
        //only if the current shape is independent, that it will be put into the result vector
        newRects.push_back(tempRect);
    }
    return newRects;
}

@end