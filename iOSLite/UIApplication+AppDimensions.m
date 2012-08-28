//
//  UIApplication+AppDimensions.m
//  iOSLite
//
//  Created by Nicholas Furness on 7/10/12.
//

#import "UIApplication+AppDimensions.h"

@implementation UIApplication (AppDimensions)
+ (CGRect) currentFrame
{
    return [UIApplication frameInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+ (CGRect) frameInOrientation:(UIInterfaceOrientation)orientation
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGPoint origin = frame.origin;
    CGSize size = frame.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        origin = CGPointMake(origin.y, origin.x);
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

+(CGSize) currentSize
{
    return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+ (CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}
@end
