//
//  EQSPortalItemPickerViewController.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSPortalItemPickerViewController.h"
#import "EQSPortalItemPickerView.h"
#import "EQSPortalItemListView_int.h"
#import "EQSBasemapTypeEnum.h"
#import "EQSHelper.h"

@interface EQSPortalItemPickerViewController () <EQSPortalItemListViewDelegate, AGSPortalItemDelegate>
@property (weak, nonatomic) IBOutlet EQSPortalItemPickerView *portalItemPickerView;
@property (weak, nonatomic) IBOutlet EQSPortalItemListView *portalItemListView;

@property (weak, nonatomic) IBOutlet UILabel *portalItemDetailsTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *portalItemDetailsDescriptionWebView;
@property (weak, nonatomic) IBOutlet UIImageView *portalItemDetailsImageView;
@end

@implementation EQSPortalItemPickerViewController
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
        [self setDetailsThumbnail:pi];
    }
    else if (keyPath == @"title")
    {
        // We were waiting for the thumbnail to load.
        NSLog(@"Title is here at last!");
        AGSPortalItem *pi = object;
        [pi removeObserver:self forKeyPath:@"title"];
        [self setDetailsTitle:pi];
    }
    else if (keyPath == @"snippet")
    {
        // We were waiting for the thumbnail to load.
        NSLog(@"Snippet is here at last!");
        AGSPortalItem *pi = object;
        [pi removeObserver:self forKeyPath:@"snippet"];
        [self setDetailsSnippet:pi];
    }
}

- (void) setDetailsThumbnail:(AGSPortalItem *)portalItem
{
    // Show the thumbnail image
    self.portalItemDetailsImageView.image = _currentPortalItem.thumbnail;
}

- (void) setDetailsTitle:(AGSPortalItem *)portalItem
{
    // Set the title text for the portal item
	self.portalItemDetailsTitleLabel.text = _currentPortalItem.title;
}

- (void) setDetailsSnippet:(AGSPortalItem *)portalItem
{
    // Load the base HTML file that we'll show in the web view.
	NSString *filePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:filePath isDirectory:YES];
	
	// Set the HTML
    NSString *htmlToShow = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"description.css\" /></head><body>%@</body></html>", _currentPortalItem.snippet];
    [self.portalItemDetailsDescriptionWebView loadHTMLString:htmlToShow baseURL:baseURL];
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
        @try {
            [_currentPortalItem removeObserver:self forKeyPath:@"title"];
        }
        @catch (NSException *exception) {
            // Do nothing - this is doubtless because we weren't registered observers.
        }
        @try {
            [_currentPortalItem removeObserver:self forKeyPath:@"snippet"];
        }
        @catch (NSException *exception) {
            // Do nothing - this is doubtless because we weren't registered observers.
        }
    }

	_currentPortalItem = currentPortalItem;
    
    [self setDetailsThumbnail:_currentPortalItem];
    [self setDetailsTitle:_currentPortalItem];
    [self setDetailsSnippet:_currentPortalItem];

    // If the thumbnail has not yet loaded, we will assume the request has been made, and will just
    // keep an eye on things and display it when it is loaded.
    if (_currentPortalItem.thumbnail == nil)
    {
        NSLog(@"Observing Portal Item Thumbnail: %@", _currentPortalItem);
        [_currentPortalItem addObserver:self
                          forKeyPath:@"thumbnail"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    }

    // If the title has not yet loaded, we will assume the request has been made, and will just
    // keep an eye on things and display it when it is loaded.
    if (_currentPortalItem.title == nil)
    {
        NSLog(@"Observing Portal Item Title");
        [_currentPortalItem addObserver:self
                             forKeyPath:@"title"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
    }
    
    // If the snippet has not yet loaded, we will assume the request has been made, and will just
    // keep an eye on things and display it when it is loaded.
    if (_currentPortalItem.snippet == nil)
    {
        NSLog(@"Observing Portal Item Snippet");
        [_currentPortalItem addObserver:self
                             forKeyPath:@"snippet"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
    }

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