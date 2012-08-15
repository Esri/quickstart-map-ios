//
//  EDNBasemapsListView.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNPortalItemsListView.h"
#import "EDNPortalItemsListViewController.h"

#import "EDNPortalItemView.h"

@interface EDNPortalItemsListView () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (strong, nonatomic) IBOutlet EDNPortalItemsListViewController *viewController;
@property (nonatomic, strong) NSMutableArray *portalItemVCs;
@end

@implementation EDNPortalItemsListView
@synthesize topLevelView;
@synthesize viewController;
@synthesize portalItemVCs;

- (NSArray *)portalItemSubViews
{
	return [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		return [evaluatedObject isKindOfClass:[EDNPortalItemView class]];
	}]];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		NSLog(@"Frame Init");
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	NSLog(@"InitWithCodered");
    if (self) {
		self.portalItemVCs = [NSMutableArray array];
		NSLog(@"Arrays: %@", self.portalItemVCs);
		
        [[NSBundle mainBundle] loadNibNamed:@"EDNPortalItemsListView" owner:self options:nil];
//		[self addSubview:self.topLevelView];
    }
    return self;
}

- (void)addPortalItem:(NSString *)portalItemID
{
	EDNPortalItemViewController *portalItemVC = [[EDNPortalItemViewController alloc] initWithPortalItemID:portalItemID];
	portalItemVC.touchDelegate = self.viewController;
	[self.portalItemVCs addObject:portalItemVC];
	[self addSubview:portalItemVC.view];
	NSLog(@"Arrays: %@", self.portalItemVCs);
	NSLog(@"Adding SubView: %d", self.portalItemVCs.count);
	[self positionItemsInView];
}

- (void)ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight
{
    // We'll scroll to put the selected item in the middle of the view.
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    for (EDNPortalItemViewController *pvc in self.portalItemVCs) {
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
	NSLog(@"Position Items In Subview...");
    // Space the items evenly in the horizontal scroll view.
    NSInteger spacing = 10;
    NSInteger x = spacing;
    NSInteger maxX = 0;
    
    UIView *containerView = self;
    CGRect tlvFrame = containerView.frame;
	
	NSInteger y = 0;

    // Place each subview in the UIScrollView appropriately
    for (EDNPortalItemView *subView in self.portalItemSubViews)
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
		
		y = oldFrame.origin.y + (oldFrame.size.height / 2) - (newHeight / 2);
		
		maxX = maxX + newWidth;
		CGRect newFrame = CGRectMake(x, (tlvFrame.size.height - newHeight)/2, newWidth, newHeight);
		subView.frame = newFrame;
		x = x + newFrame.size.width + spacing;
		maxX = x;
    }

    // Set the total content area to a space large enough to include everything.
    UIScrollView *tv = (UIScrollView *)containerView;
    tv.contentSize = CGSizeMake(maxX, tlvFrame.size.height);
}
@end
