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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EDNBasemapsListView" owner:self options:nil];
    }
    return self;
}

- (void)addBasemapItem:(EDNBasemapItemViewController *)item
{
    [self addSubview:item.view];
}

- (void)ensureItemVisible:(EDNLiteBasemapType)basemapType Highlighted:(BOOL)highlight
{
    // We'll scroll to put the selected item in the middle of the view.
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    for (EDNBasemapItemViewController *bvc in self.viewController.basemapVCs) {
        if (bvc.basemapType == basemapType)
        {
            CGFloat targetMidX = CGRectGetMidX(bvc.view.frame);
            CGFloat targetMidY = CGRectGetMidY(bvc.view.frame);
            CGRect frameToScrollTo = CGRectMake(targetMidX - w/2, targetMidY - h/2, w, h);
            [self scrollRectToVisible:frameToScrollTo animated:YES];
            bvc.highlighted = highlight;
        }
        else {
            bvc.highlighted = NO;
        }
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self positionItemsInView];
}

- (void) positionItemsInView
{
    // Space the items evenly in the horizontal scroll view.
    NSInteger spacing = 10;
    NSInteger x = spacing;
    NSInteger maxX = 0;
    
    UIView *containerView = self;
    CGRect tlvFrame = containerView.frame;
    
    // Go over each subview I have. There are some which I don't put in here,
    // and which I think might be the scroll-bars, so I check for the class type.
    for (UIView *subView in containerView.subviews) 
    {
        if (![subView isKindOfClass:[UIImageView class]])
        {
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
            x = x + newFrame.size.width + spacing;
            maxX = x;
        }
    }

    // Set the total content area to a space large enough to include everything.
    UIScrollView *tv = (UIScrollView *)containerView;
    tv.contentSize = CGSizeMake(maxX, tlvFrame.size.height);
}

@end
