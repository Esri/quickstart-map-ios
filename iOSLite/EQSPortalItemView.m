//
//  EQSPortalItemView.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSPortalItemView.h"
#import "EQSPortalItemViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface EQSPortalItemView ()
@property (nonatomic, retain) UIColor *defaultBackgroundColor;
@end

@implementation EQSPortalItemView
@synthesize highlighted = _highlighted;
@synthesize defaultBackgroundColor = _defaultBackgroundColor;

@synthesize viewController = _viewController;

- (void)doSetup
{
	self.layer.cornerRadius = 10;
	
	// Read the default background color to be used when not highlighted.
    self.defaultBackgroundColor = self.backgroundColor;	
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self doSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self doSetup];
    }
    return self;
}

- (EQSPortalItemViewLoadingState)loadingState
{
    return self.viewController.loadingState;
}

- (NSString *) portalItemID
{
	return self.viewController.portalItemID;
}
- (AGSPortalItem *) portalItem
{
	return self.viewController.portalItem;
}

- (BOOL)highlighted
{
    return _highlighted;
}

- (void)setHighlighted:(BOOL)highlighted
{
    CGFloat defaultAlpha = CGColorGetAlpha(self.defaultBackgroundColor.CGColor);
    
    _highlighted = highlighted;
    [UIView animateWithDuration:0.25 animations:^{
        if (_highlighted)
        {
            self.backgroundColor = [UIColor colorWithWhite:0.35 alpha:defaultAlpha];
            self.alpha = 1;
        }
        else
        {
            self.backgroundColor = self.defaultBackgroundColor;
            self.alpha = 0.5;
        }
    }];
}

- (void) dealloc
{
	self.viewController = nil;
	self.defaultBackgroundColor = nil;
}
@end