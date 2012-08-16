//
//  STXPortalItemPickerViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "STXPortalItemPickerViewController.h"
#import "STXPortalItemPickerView.h"
#import "STXPortalItemListView_int.h"
#import "STXBasemapTypeEnum.h"
#import "STXHelper.h"

@interface STXPortalItemPickerViewController () <STXPortalItemListViewDelegate, AGSPortalItemDelegate>
@property (weak, nonatomic) IBOutlet STXPortalItemPickerView *portalItemPickerView;
@property (weak, nonatomic) IBOutlet STXPortalItemListView *portalItemListView;

@property (weak, nonatomic) IBOutlet UILabel *portalItemDetailsTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *portalItemDetailsDescriptionWebView;
@property (weak, nonatomic) IBOutlet UIImageView *portalItemDetailsImageView;
@end

@implementation STXPortalItemPickerViewController
@synthesize portalItemPickerView = _portalItemPickerView;
@synthesize portalItemListView = _portalItemListView;

@synthesize currentPortalItemID = _currentPortalItemID;
@synthesize currentPortalItem = _currentPortalItem;

@synthesize portalItemDetailsTitleLabel = _currentBasemapNameLabel;
@synthesize portalItemDetailsDescriptionWebView = _currentBasemapDescriptionWebView;
@synthesize portalItemDetailsImageView = _currentBasemapImageView;

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"thumbnail")
    {
        // We were waiting for the thumbnail to load.
        NSLog(@"Thumbnail is here at last!");
        AGSPortalItem *pi = object;
        [pi removeObserver:self forKeyPath:@"thumbnail"];
        self.portalItemDetailsImageView.image = pi.thumbnail;
    }
}

- (void) setCurrentPortalItem_Int:(AGSPortalItem *)currentPortalItem callingDelegate:(BOOL)callDelegate
{
    if (_currentPortalItem)
    {
        @try {
            [_currentPortalItem removeObserver:self forKeyPath:@"thumbnail"];
        }
        @catch (NSException *exception) {
            // Do nothing - this is doubtless because we weren't registered observers.
        }
    }

	_currentPortalItem = currentPortalItem;

    // Show the thumbnail image
    self.portalItemDetailsImageView.image = _currentPortalItem.thumbnail;
    
    // If the thumbnail has not yet loaded, we will assume the request has been made, and will just
    // keep an eye on things and display it when it is loaded.
    if (_currentPortalItem.thumbnail == nil)
    {
        NSLog(@"Observing Portal Item Thumbnail");
        [_currentPortalItem addObserver:self
                          forKeyPath:@"thumbnail"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    }

    // Set the title text for the portal item
	self.portalItemDetailsTitleLabel.text = _currentPortalItem.title;
	
    // Load the base HTML file that we'll show in the web view.
	NSString *filePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:filePath isDirectory:YES];
	
	// Set the HTML
    NSString *htmlToShow = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"description.css\" /></head><body>%@</body></html>", _currentPortalItem.snippet];
    [self.portalItemDetailsDescriptionWebView loadHTMLString:htmlToShow baseURL:baseURL];
	
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
@end