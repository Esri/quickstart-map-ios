//
//  EDNBasemapsListViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNPortalItemsListView.h"
#import "EDNPortalItemsListViewController.h"
#import "EDNPortalItemViewController.h"

#import "EDNPortalItemView.h"

@interface EDNPortalItemsListViewController () <PortalItemViewTouchDelegate>
@property (weak, nonatomic) IBOutlet EDNPortalItemsListView *portalItemsListView;

@property (nonatomic, strong) NSMutableArray *portalItemVCs;
@end

@implementation EDNPortalItemsListViewController
@synthesize portalItemsListView = _portalItemsListView;

@synthesize portalItemVCs = _portalItemVCs;

- (void) portalItemViewTapped:(EDNPortalItemView *)portalItemView
{
	NSLog(@"Tapped a basemap!");
	[self.portalItemsListView ensureItemVisible:portalItemView.portalItemID Highlighted:YES];
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
    NSLog(@"View unloaded");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
