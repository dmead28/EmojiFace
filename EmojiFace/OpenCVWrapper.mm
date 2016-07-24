//
//  OpenCVWrapper.m
//  EmojiFace
//
//  Created by Douglas Mead on 7/23/16.
//  Copyright © 2016 Doug. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/core/core.hpp"


@implementation OpenCVWrapper

+ (NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

+ (UIImage *) warpSmiley:(UIImage *)originalImage fromPoints:(NSArray *)basePoints toPoints:(NSArray *)points usingSize:(CGSize)newSize {
    
    // Some transform code taken from: http://www.learnopencv.com/homography-examples-using-opencv-python-c/
    
    cv::Mat unsizedImage =  [self cvMatFromUIImage: originalImage];
    cv::Mat image;
    cv::Mat newImage;
    cv::Size cvSize = cv::Size(newSize.width, newSize.height);
    
    cv::resize(unsizedImage, image, cvSize);
    
    std::vector<cv::Point2f> srcPoints;
    std::vector<cv::Point2f> dstPoints;
    
    //NSLog(@"Count: %lu", (unsigned long)points.count);
    for (int i = 0; i < basePoints.count; i++) {
        CGPoint point = [[basePoints objectAtIndex: i] CGPointValue];
        srcPoints.push_back(cv::Point2f(point.x,point.y));
    }
    for (int i = 0; i < points.count; i++) {
        CGPoint point = [[points objectAtIndex: i] CGPointValue];
        dstPoints.push_back(cv::Point2f(point.x,point.y));
    }
    
    //# Calculate Homography
    //h, status = cv2.findHomography(originalPoints, newPoints)
    cv::Mat homography = findHomography(srcPoints, dstPoints);
    
    //# Warp source image to destination based on homography
    //newImage = cv2.warpPerspective(image, h, (image.shape[1],image.shape[0]))
    warpPerspective(image, newImage, homography, cvSize);
    
    UIImage * newImageOutput = [self UIImageFromCVMat: newImage];
    
    return newImageOutput;
}

+ (UIImage *) testConvertBackAndForth:(UIImage *)image {
    cv::Mat convertedImage = [self cvMatFromUIImage: image];
    UIImage * originalImage = [self UIImageFromCVMat: convertedImage];
    return originalImage;
}

// These functions taken from: http://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    // Temp fix for issue with alpha background
    CGContextSetRGBFillColor(contextRef, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextFillRect(contextRef, CGRectMake(0, 0, cols, rows));
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    
    CGContextRelease(contextRef);
    
    return cvMat;
}
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end


/*
# http://www.learnopencv.com/homography-examples-using-opencv-python-c/

image = cv2.imread('normalFace.png')

maxPixelY = image.shape[0] - 1
maxPixelX = image.shape[1] - 1

leftEye = [163, 213]
rightEye = [163 + 185, 213]
leftMouth = [163 - 15, 213 + 100 + 10]
rightMouth = [163 + 185 + 15, 213 + 100 + 10]

originalPoints = np.array([
                           leftEye,
                           rightEye,
                           leftMouth,
                           rightMouth,
                           ]).astype(np.float)

frownOffset = 100
newPoints = np.array([
                      [leftEye[0], leftEye[1]],
                      [rightEye[0], rightEye[1]],
                      [leftMouth[0], leftMouth[1] + frownOffset],
                      [rightMouth[0], rightMouth[1] + frownOffset],
                      ]).astype(np.float)


# Calculate Homography
h, status = cv2.findHomography(originalPoints, newPoints)

print "h", h
print "status", status

# Warp source image to destination based on homography
newImage = cv2.warpPerspective(image, h, (image.shape[1],image.shape[0]))
#newImageTransform = cv2.perspectiveTransform(image, h)

# Show points (5x5 square)
squareSize = 10
for point in originalPoints:
for i in range(squareSize):
for j in range(squareSize):
x = point[0] + i - squareSize/2
y = point[1] + j - squareSize/2
if not (x > len(image) - 1 or x < 0 or y > len(image[0]) - 1 or y < 0):
image[y][x] = [100., 200., 0.]

for point in newPoints:
for i in range(squareSize):
for j in range(squareSize):
x = point[0] + i - squareSize/2
y = point[1] + j - squareSize/2
if not (x > len(image) - 1 or x < 0 or y > len(image[0]) - 1 or y < 0):
image[y][x] = [255., 0., 0.]


# Save images (if necessary)
saveReason = ""
if len(saveReason) > 0:
originalStr = "ReportImages/" + saveReason + "_orig.png"
newStr = "ReportImages/" + saveReason + "_new.png"

cv2.imwrite(originalStr, image)
cv2.imwrite(newStr, newImage)

# Display images
cv2.imshow("WarpPerspective Image", newImage)
#cv2.imshow("PerspectiveTransform Image", newImageTransform)
cv2.imshow("Source Image with Points", image)

cv2.waitKey(0)
*/