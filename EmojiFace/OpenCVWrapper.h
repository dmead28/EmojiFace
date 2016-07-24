//
//  OpenCVWrapper.h
//  EmojiFace
//
//  Created by Douglas Mead on 7/23/16.
//  Copyright © 2016 Doug. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (NSString *) openCVVersionString;

+ (UIImage *) warpSmiley:(UIImage *)originalImage fromPoints:(NSArray *)basePoints toPoints:(NSArray *)points usingSize:(CGSize)newSize;

+ (UIImage *) testConvertBackAndForth:(UIImage *)image;

@end
