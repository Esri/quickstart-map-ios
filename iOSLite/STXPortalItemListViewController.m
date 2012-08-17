//
//  STXPortalItemListViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "STXPortalItemListView_int.h"
#import "STXPortalItemListViewController.h"
#import "STXPortalItemViewController.h"

#import "STXPortalItemView.h"

@interface STXPortalItemListViewController () <PortalItemViewTouchDelegate>
@property (weak, nonatomic) IBOutlet STXPortalItemListView *portalItemsListView;
@end

@implementation STXPortalItemListViewController
@synthesize portalItemsListView = _portalItemsListView;

@synthesize portalItemDelegate = _portalItemDelegate;

- (void) portalItemViewTapped:(STXPortalItemView *)portalItemView
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
