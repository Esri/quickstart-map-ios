//
//  EDNBasemapsListView.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNBasemapsListView.h"
#import "EDNBasemapsListViewController.h"

@interface EDNBasemapsListView () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (strong, nonatomic) IBOutlet EDNBasemapsListViewController *viewController;
@end

@implementation EDNBasemapsListView
@synthesize topLevelView;
@synthesize viewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSLog(@"BasemapListView InitWithFrame");
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"BasemapListView InitWithCoder");
        [[NSBundle mainBundle] loadNibNamed:@"EDNBasemapsListView" owner:self options:nil];
        [self addSubview:self.topLevelView];
    }
    return self;
}

- (void)addBasemapItem:(EDNBasemapItemViewController *)item
{
    [self.topLevelView addSubview:item.view];
}

- (void)ensureItemVisible:(EDNLiteBasemapType)basemapType
{
    UIScrollView *sView = self.topLevelView;
    for (EDNBasemapItemViewController *bvc in self.viewController.basemapVCs) {
        if (bvc.basemapType == basemapType)
        {
            CGRect frameToScrollTo = bvc.view.frame;
            [sView scrollRectToVisible:frameToScrollTo animated:YES];
            break;
        }
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"Layout Subviews");
    self.topLevelView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self positionItemsInView];
}

- (void) positionItemsInView
{
    // Space the items evenly in the horizontal scroll view.
    NSInteger spacing = 10;
    NSInteger x = spacing;
    NSInteger maxX = 0;
    
    UIView *containerView = self.topLevelView;
    CGRect tlvFrame = containerView.frame;
    
    for (UIView *subView in containerView.subviews) 
    {
        if (![subView isKindOfClass:[UIImageView class]])
        {
            NSLog(@"Subview: %@", subView);
            CGRect oldFrame = subView.frame;
            NSInteger newHeight = oldFrame.size.height;
            NSInteger newWidth = oldFrame.size.width;
            if (newHeight > tlvFrame.size.height)
            {
                double scale = tlvFrame.size.height / newHeight;
                scale = scale * 0.9;
                subView.transform = CGAffineTransformMakeScale(scale, scale);
                newWidth = newWidth * scale;
                newHeight = newHeight * scale;
            }
            
            maxX = maxX + newWidth;
            CGRect newFrame = CGRectMake(x, (tlvFrame.size.height - newHeight)/2, newWidth, newHeight);
            subView.frame = newFrame;
            NSLog(@"Basemap View: %@", NSStringFromCGRect(subView.frame));
            x = x + newFrame.size.width + spacing;
            maxX = x;
        }
    }
    
    UIScrollView *tv = (UIScrollView *)containerView;
    tv.contentSize = CGSizeMake(maxX, tlvFrame.size.height);
}

@end
