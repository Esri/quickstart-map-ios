//
//  EQSPortalItemViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSPortalItemViewController.h"
#import "UILabel+EQSAutoSizeMultiline.h"

@interface EQSPortalItemViewController () <AGSPortalDelegate, AGSPortalItemDelegate>
@property (nonatomic, strong) AGSPortal *portal;
@property (nonatomic, strong, readwrite) AGSPortalItem *portalItem;
@property (nonatomic, strong) NSString *portalItemID;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

- (IBAction)basemapTapped:(id)sender;
@end

@implementation EQSPortalItemViewController

@synthesize portal = _portal;
@synthesize portalItem = _portalItem;
@synthesize portalItemID = _portalItemID;
@synthesize portalItemView = _portalItemView;
@synthesize imageView = _portalImageView;
@synthesize label = _portalLabel;
@synthesize activitySpinner = _activitySpinner;

@synthesize loadingState = _loadingState;


#pragma mark - Initialization
- (id)initWithPortalItemID:(NSString *)portalItemID
{
    self = [super initWithNibName:@"EQSPortalItemView" bundle:nil];
 
    if (self)
    {
        // Store the portal Item ID for later loading
        self.portalItemID = portalItemID;
        self.loadingState = EQSPortalItemViewLoadingStateNew;
    }

    return self;
}


#pragma mark - UIView Handler
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Load the portal.
    self.loadingState = EQSPortalItemViewLoadingStatePortalLoading;
    self.portal = [[AGSPortal alloc] initWithURL:[NSURL URLWithString:@"http://www.arcgis.com"] credential:nil];
    self.portal.delegate = self;
}


#pragma mark - Load Portal Item
- (void) portalDidLoad:(AGSPortal *)portal
{
    self.loadingState = EQSPortalItemViewLoadingStatePortalLoaded;
    self.portalItem = [[AGSPortalItem alloc] initWithPortal:portal itemId:self.portalItemID];
}

- (void)setPortalItem:(AGSPortalItem *)portalItem
{
    self.loadingState = EQSPortalItemViewLoadingStatePortalItemLoading;
    _portalItem = portalItem;
    _portalItem.delegate = self;
}

- (void)portalItemDidLoad:(AGSPortalItem *)portalItem
{
    self.loadingState = EQSPortalItemViewLoadingStatePortalItemLoaded;
    
    self.label.text = portalItem.title;
	NSString *infoText = portalItem.title;
	
	if ([infoText componentsSeparatedByString:@" "].count == 1)
	{
		// If there's a single word, make sure we don't try to break it over two lines
		self.label.numberOfLines = 1;
	}
	else
	{
		// Otherwise, we can drift over two lines if we want.
		self.label.numberOfLines = 2;
	}
    
	self.label.text = portalItem.title;
	[self.label setFontSizeToFit];
    
    [portalItem fetchThumbnail];
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchThumbnail:(UIImage *)thumbnail
{
    self.loadingState = EQSPortalItemViewLoadingStatePortalItemLoadedWithThumbnail;
    self.imageView.image = thumbnail;
}

#pragma mark - Loading State
- (void) setLoadingState:(EQSPortalItemViewLoadingState)loadingState
{
    _loadingState = loadingState;
    switch (_loadingState) {
        case EQSPortalItemViewLoadingStateNew:
            self.label.text = nil;
            self.imageView.image = nil;
            break;
        case EQSPortalItemViewLoadingStatePortalLoading:
            [self.activitySpinner startAnimating];
        case EQSPortalItemViewLoadingStatePortalItemLoading:
            self.label.text = @"loading...";
            break;
        case EQSPortalItemViewLoadingStatePortalItemLoadedWithThumbnail:
            [self.activitySpinner stopAnimating];
            break;            
        default:
            break;
    }
}


#pragma mark - Service Error Handlers
- (void) portal:(AGSPortal *)portal didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Could not load portal: %@", error);
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFailToFetchThumbnailWithError:(NSError *)error
{
    NSLog(@"Failed to load thumbnail! %@", error.debugDescription);
}


#pragma mark - UI Handler
- (IBAction)basemapTapped:(id)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"BasemapSelected" object:self];
	if (self.touchDelegate &&
		[self.touchDelegate respondsToSelector:@selector(portalItemViewTapped:)])
	{
		[self.touchDelegate portalItemViewTapped:self.portalItemView];
	}
}


#pragma mark - Unload
- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLabel:nil];
    [self setPortal:nil];
    [self setPortalItemID:nil];
    [self setPortalItem:nil];
    
	[self setPortalItemView:nil];
    [self setActivitySpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
@end
