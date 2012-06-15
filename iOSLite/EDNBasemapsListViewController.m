//
//  EDNBasemapsListViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNBasemapsListView.h"
#import "EDNBasemapsListViewController.h"
#import "EDNBasemapItemViewController.h"
#import "EDNLiteHelper.h"
#import "EDNLiteBasemaps.h"

@interface EDNBasemapsListViewController ()
@property (weak, nonatomic) IBOutlet EDNBasemapsListView *basemapListView;
@end

@implementation EDNBasemapsListViewController
@synthesize basemapListView = _basemapListView;
@synthesize basemapVCs = _basemapVCs;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        NSLog(@"BasemapVC InitWithCoder");
        self.basemapVCs = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"BVC VIEW: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"%d",self.view.subviews.count);

    // Do any additional setup after loading the view from its nib.
    for (EDNLiteBasemapType type = EDNLiteBasemapFirst; type <= EDNLiteBasemapLast; type++)
    {
        AGSWebMap *wm = [EDNLiteHelper getBasemapWebMap:type];
        AGSPortalItem *pi = wm.portalItem;
        EDNBasemapItemViewController *bvc = [[EDNBasemapItemViewController alloc] initWithPortalItemID:pi.itemId
                                             forBasemapType:type];
        [self.basemapVCs addObject:bvc];
        [self.basemapListView addBasemapItem:bvc];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"View unloaded");
    self.basemapVCs = nil;
    self.basemapListView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
