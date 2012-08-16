//
//  EDNBasemapsPickerViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNPortalItemsPickerViewController.h"
#import "EDNPortalItemsPickerView.h"
#import "EDNPortalItemsListView_int.h"
#import "EDNLiteBasemaps.h"
#import "EDNLiteHelper.h"

@interface EDNPortalItemsPickerViewController () <EDNPortalItemsListViewDelegate>
@property (weak, nonatomic) IBOutlet EDNPortalItemsPickerView *portalItemPickerView;
@property (weak, nonatomic) IBOutlet EDNPortalItemsListView *portalItemListView;

@property (weak, nonatomic) IBOutlet UILabel *currentBasemapNameLabel;
@property (weak, nonatomic) IBOutlet UIWebView *currentBasemapDescriptionWebView;
@property (weak, nonatomic) IBOutlet UIImageView *currentBasemapImageView;
@end

@implementation EDNPortalItemsPickerViewController
@synthesize portalItemPickerView = _portalItemPickerView;
@synthesize portalItemListView = _portalItemListView;

@synthesize currentPortalItemID = _currentPortalItemID;
@synthesize currentPortalItem = _currentPortalItem;

@synthesize currentBasemapNameLabel = _currentBasemapNameLabel;
@synthesize currentBasemapDescriptionWebView = _currentBasemapDescriptionWebView;
@synthesize currentBasemapImageView = _currentBasemapImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.portalItemListView.viewController.portalItemDelegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setCurrentPortalItemID:(NSString *)currentPortalItemID
{
	for (AGSPortalItem *pi in self.portalItemListView.portalItems) {
		if ([pi.itemId isEqualToString:currentPortalItemID])
		{
			[self setCurrentPortalItem:pi];
			break;
		}
	}
}

- (void)selectedPortalItemChanged:(AGSPortalItem *)selectedPortalItem
{
	// If it's the case that the user has selected a different portal item, then we
	// want to notify our delegate.
	[self setCurrentPortalItem_Int:selectedPortalItem callingDelegate:YES];
}

- (void) setCurrentPortalItem_Int:(AGSPortalItem *)currentPortalItem callingDelegate:(BOOL)callDelegate
{
	_currentPortalItem = currentPortalItem;
	
	self.currentBasemapNameLabel.text = _currentPortalItem.title;
	
    // Load the base HTML file that we'll show in the web view.
	NSString *filePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:filePath isDirectory:YES];
	
	// Set the HTML
    NSString *htmlToShow = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"description.css\" /></head><body>%@</body></html>", _currentPortalItem.snippet];
    [self.currentBasemapDescriptionWebView loadHTMLString:htmlToShow baseURL:baseURL];
	
	// Show the image
	self.currentBasemapImageView.image = _currentPortalItem.thumbnail;

	if (callDelegate)
	{
		if ([self.portalItemPickerView.pickerDelegate respondsToSelector:@selector(currentPortalItemChanged:)])
		{
			[self.portalItemPickerView.pickerDelegate currentPortalItemChanged:_currentPortalItem];
		}
	}
}

- (void) setCurrentPortalItem:(AGSPortalItem *)currentPortalItem
{
	// TODO - revisit this.
	// If the property has been updated from without, don't raise the delegate
	[self setCurrentPortalItem_Int:currentPortalItem callingDelegate:NO];
	[self.portalItemListView ensureItemVisible:currentPortalItem.itemId Highlighted:YES];
}

- (AGSPortalItem *) currentPortalItem
{
	return _currentPortalItem;
}

- (AGSPortalItem *) addPortalItemByID:(NSString *)portalItemID
{
	return [self.portalItemListView addPortalItem:portalItemID];
}

- (void) ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight
{
	[self.portalItemListView ensureItemVisible:portalItemID Highlighted:highlight];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
//
@end