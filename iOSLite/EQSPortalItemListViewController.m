//
//  EQSPortalItemListViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSPortalItemListView_int.h"
#import "EQSPortalItemListViewController.h"
#import "EQSPortalItemViewController.h"

#import "EQSPortalItemView.h"

@interface EQSPortalItemListViewController () <PortalItemViewTouchDelegate>
@property (weak, nonatomic) IBOutlet EQSPortalItemListView *portalItemsListView;
@end

@implementation EQSPortalItemListViewController
@synthesize portalItemsListView = _portalItemsListView;

@synthesize portalItemDelegate = _portalItemDelegate;

- (void) portalItemViewTapped:(EQSPortalItemView *)portalItemView
{
	[self.portalItemsListView ensureItemVisible:portalItemView.portalItemID Highlighted:YES];
	
	if ([self.portalItemDelegate respondsToSelector:@selector(selectedPortalItemChanged:)]);
	{
		[self.portalItemDelegate selectedPortalItemChanged:portalItemView.portalItem];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.portalItemsListView = nil;
}
@end