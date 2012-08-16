//
//  EDNBasemapsListViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNPortalItemsListView_int.h"
#import "EDNPortalItemsListViewController.h"
#import "EDNPortalItemViewController.h"

#import "EDNPortalItemView.h"

@interface EDNPortalItemsListViewController () <PortalItemViewTouchDelegate>
@property (weak, nonatomic) IBOutlet EDNPortalItemsListView *portalItemsListView;
@end

@implementation EDNPortalItemsListViewController
@synthesize portalItemsListView = _portalItemsListView;

@synthesize portalItemDelegate = _portalItemDelegate;

- (void) portalItemViewTapped:(EDNPortalItemView *)portalItemView
{
	NSLog(@"Tapped a basemap!");
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

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
@end
