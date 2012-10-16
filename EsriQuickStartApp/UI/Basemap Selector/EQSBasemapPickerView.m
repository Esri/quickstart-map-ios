//
//  EQSBasemapPickerView.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//
//  This subclass of the PortalItemsPickerView abstracts the AGSPortalItem behaviour away from
//  the user. Instead, the control's interface works on the EQSBasemapType enumeration.

#import <EsriQuickStart/EsriQuickStart.h>

#import "EQSBasemapPickerView.h"

// We modify the interface declaration here to show that we're going to implement
// the <EQSPortalItemPickerDelegate> handler
@interface EQSBasemapPickerView () <EQSPortalItemPickerDelegate>

@end

@implementation EQSBasemapPickerView
// Synthesize the properties (not needed from Xcode 4.4.1 onwards)
@synthesize basemapType = _basemapType;
@synthesize basemapDelegate = _basemapDelegate;

#pragma mark - UIView initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self populateWithBasemaps];
        self.pickerDelegate = self;
    }
    return self;
}

#pragma mark - Basemap Specific functions
// Load the PortalItemPicker with portal items which represent the basemaps
- (void)populateWithBasemaps
{
    // Loop over all the basemap types we have enumerated
	for (EQSBasemapType type = EQSBasemapTypeFirst; type <= EQSBasemapTypeLast; type++)
    {
        // Use the helper to get a portal item for the basemap type
        NSString *portalItemID = [EQSHelper getPortalItemIDForBasemap:type];

		// Add the portal item to this PortalItemsPickerView
        [self addPortalItemByID:portalItemID];
    }
}

// Explicit setter definition for the basemapType property
- (void)setBasemapType:(EQSBasemapType)basemapType
{
    // Set the iVar
	_basemapType = basemapType;
	
    // Get hold of the WebMap for the Basemap Type
	AGSWebMap *wm = [EQSHelper getBasemapWebMap:_basemapType];
    // Then get hold of the Portal Item
	AGSPortalItem *pi = wm.portalItem;
    // And lastly read the ItemID off the Portal Item.
	NSString *portalID = pi.itemId;
    // And store it as the current portal item ID
	self.currentPortalItemID = portalID;
}

#pragma mark - EQSPortalItemPickerDelegate handlers
- (void)currentPortalItemChanged:(AGSPortalItem *)currentPortalItem
{
    // Translate the PortalItem into a BasemapType
	EQSBasemapType newType = [EQSHelper getBasemapTypeForPortalItemID:currentPortalItem.itemId];
	
    // Bubble this up using our custom BasemapType based delegate handler
	if ([self.basemapDelegate respondsToSelector:@selector(basemapSelected:)])
	{
		[self.basemapDelegate basemapSelected:newType];
	}
}

- (void)basemapsPickerDidTapInfoButton:(id)basemapsPicker
{
    // Bubble this on up to our delegate handler (if any)
	if ([self.basemapDelegate respondsToSelector:@selector(basemapsPickerDidTapInfoButton:)])
	{
		[self.basemapDelegate basemapsPickerDidTapInfoButton:self];
	}
}
@end
