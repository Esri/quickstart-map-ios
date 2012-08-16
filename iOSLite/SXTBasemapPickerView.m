//
//  SXTBasemapPickerView.m
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "SXTBasemapPickerView.h"
#import "EDNLiteHelper.h"

@interface SXTBasemapPickerView () <EDNBasemapsPickerDelegate>

@end

@implementation SXTBasemapPickerView

@synthesize basemapType = _basemapType;
@synthesize basemapDelegate = _basemapDelegate;

- (void)populateWithBasemaps
{
	for (EDNLiteBasemapType type = EDNLiteBasemapFirst; type <= EDNLiteBasemapLast; type++)
    {
        AGSWebMap *wm = [EDNLiteHelper getBasemapWebMap:type];
        AGSPortalItem *pi = wm.portalItem;
		
		NSLog(@"Adding Portal Item: %@", pi.itemId);
        [self addPortalItemByID:pi.itemId];
    }
}

- (void)setBasemapType:(EDNLiteBasemapType)basemapType
{
	_basemapType = basemapType;
	
	AGSWebMap *wm = [EDNLiteHelper getBasemapWebMap:_basemapType];
	AGSPortalItem *pi = wm.portalItem;
	NSString *portalID = pi.itemId;
	self.currentPortalItemID = portalID;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self populateWithBasemaps];
    }
    return self;
}

- (void) awakeFromNib
{
	[self populateWithBasemaps];
	self.pickerDelegate = self;
}

- (void)currentPortalItemChanged:(AGSPortalItem *)currentPortalItem
{
	EDNLiteBasemapType newType = [EDNLiteHelper getBasemapTypeForPortalItemID:currentPortalItem.itemId];
	
	if ([self.basemapDelegate respondsToSelector:@selector(basemapSelected:)])
	{
		[self.basemapDelegate basemapSelected:newType];
	}
}

- (void)basemapsPickerDidTapInfoButton:(id)basemapsPicker
{
	if ([self.basemapDelegate respondsToSelector:@selector(basemapsPickerDidTapInfoButton:)])
	{
		[self.basemapDelegate basemapsPickerDidTapInfoButton:self];
	}
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
