//
//  UIApplication+AppDimensions.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/10/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (AppDimensions)
+ (CGRect) currentFrame;
+ (CGRect) frameInOrientation:(UIInterfaceOrientation)orientation;
+ (CGSize) currentSize;
+ (CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;
@end
