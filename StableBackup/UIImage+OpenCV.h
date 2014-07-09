#import <UIKit/UIKit.h>
#import "opencv2/opencv.hpp"

@interface UIImage (UIImage_OpenCV)

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;
@property(nonatomic, readonly) cv::Mat CVMat8UC3;

@end
