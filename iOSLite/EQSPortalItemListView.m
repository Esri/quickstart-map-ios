//
//  EQSPortalItemListView.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSPortalItemListView.h"
#import "EQSPortalItemListViewController.h"

#import "EQSPortalItemViewController.h"

#import "EQSPortalItemView.h"

@interface EQSPortalItemListView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *portalItemVCs;

- (void) positionItemsInView;
@end

@implementation EQSPortalItemListView
@synthesize viewController;
@synthesize portalItemVCs;

- (NSArray *)portalItems
{
	NSMutableArray *result = [NSMutableArray array];
	for (EQSPortalItemView *piv in [self portalItemViews]) {
		if (piv.portalItem)
			[result addObject:piv.portalItem];
	}
	return result;
}

- (NSArray *)portalItemViews
{
	return [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		return [evaluatedObject isKindOfClass:[EQSPortalItemView class]];
	}]];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		self.portalItemVCs = [NSMutableArray array];
		
        [[NSBundle mainBundle] loadNibNamed:@"EQSPortalItemListView" owner:self options:nil];
    }
    return self;
}

- (AGSPortalItem *)addPortalItem:(NSString *)portalItemID
{
	EQSPortalItemViewController *portalItemVC = [[EQSPortalItemViewController alloc] initWithPortalItemID:portalItemID];
	portalItemVC.touchDelegate = self.viewController;
	[self.portalItemVCs addObject:portalItemVC];
	[self addSubview:portalItemVC.view];
	[self positionItemsInView];
	
	return portalItemVC.portalItem;
}

- (void)ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight
{
    // We'll scroll to put the selected item in the middle of the view.
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    for (EQSPortalItemViewController *pvc in self.portalItemVCs) {
        if ([pvc.portalItem.itemId isEqualToString:portalItemID])
        {
            CGFloat targetMidX = CGRectGetMidX(pvc.portalItemView.frame);
            CGFloat targetMidY = CGRectGetMidY(pvc.portalItemView.frame);
            CGRect frameToScrollTo = CGRectMake(targetMidX - w/2, targetMidY - h/2, w, h);
            [self scrollRectToVisible:frameToScrollTo animated:YES];
			pvc.portalItemView.highlighted = highlight;
        }
        else {
			pvc.portalItemView.highlighted = NO;
        }
    }
}

- (void) positionItemsInView
{
    // Space the items evenly in the horizontal scroll view.
    NSInteger spacing = 10;
    NSInteger x = spacing;
    NSInteger maxX = 0;
    
    UIView *containerView = self;
    CGRect tlvFrame = containerView.frame;
	
	NSInteger y = 0;

    // Place each subview in the UIScrollView appropriately
    for (EQSPortalItemView *subView in self.portalItemViews)
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

		y = (tlvFrame.size.height - newHeight) / 2;
		
		CGRect newFrame = CGRectMake(x, y, newWidth, newHeight);
		subView.frame = newFrame;
		x = x + newWidth + spacing;
		maxX = x;
    }

    // Set the total content area to a space large enough to include everything.
    UIScrollView *tv = (UIScrollView *)containerView;
    tv.contentSize = CGSizeMake(maxX, tlvFrame.size.height);
}
@end