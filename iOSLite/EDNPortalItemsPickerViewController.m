//
//  EDNBasemapsPickerViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNPortalItemsPickerViewController.h"
#import "EDNPortalItemsListView.h"
#import "EDNLiteBasemaps.h"
#import "EDNLiteHelper.h"

@interface EDNPortalItemsPickerViewController ()
@property (weak, nonatomic) IBOutlet EDNPortalItemsListView *portalItemListView;
@end

@implementation EDNPortalItemsPickerViewController
@synthesize portalItemListView = _portalItemListView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) populateForDefaultBasemaps
{
    for (EDNLiteBasemapType type = EDNLiteBasemapFirst; type <= EDNLiteBasemapLast; type++)
    {
        AGSWebMap *wm = [EDNLiteHelper getBasemapWebMap:type];
        AGSPortalItem *pi = wm.portalItem;
		
		NSLog(@"Adding Portal Item: %@", pi.itemId);
        [self.portalItemListView addPortalItem:pi.itemId];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self populateForDefaultBasemaps];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (AGSPortalItem *) currentPortalItem
{
	return nil;
}

- (void) addPortalItemByID:(NSString *)portalItemID
{
	[self.portalItemListView addPortalItem:portalItemID];
}

- (void) ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight
{
	[self.portalItemListView ensureItemVisible:portalItemID Highlighted:highlight];
}

@end
