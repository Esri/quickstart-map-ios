//
//  EDNBasemapItemViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNBasemapItemViewController.h"
#import "UILabel+EDNAutoSizeMutliline.h"
#import "EDNLiteHelper.h"

@interface EDNBasemapItemViewController () <AGSPortalDelegate, AGSPortalItemDelegate>
@property (nonatomic, strong) AGSPortal *portal;
@property (nonatomic, strong, readwrite) AGSPortalItem *portalItem;
@property (nonatomic, assign, readwrite) EDNLiteBasemapType basemapType;
@property (nonatomic, retain) NSString *portalItemID;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)basemapTapped:(id)sender;
@end

@implementation EDNBasemapItemViewController

@synthesize portal = _portal;
@synthesize portalItem = _portalItem;
@synthesize portalItemID = _portalItemID;
@synthesize imageView = _portalImageView;
@synthesize label = _portalLabel;
@synthesize basemapType = _basemapType;

- (id)initWithPortalItemID:(NSString *)portalItemID forBasemapType:(EDNLiteBasemapType)basemapType
{
    self = [super initWithNibName:@"EDNBasemapItemView" bundle:nil];
 
    if (self)
    {
        // Store the portal Item ID for later loading
        self.portalItemID = portalItemID;
        self.basemapType = basemapType;
        NSLog(@"Portal Item: %@", self.portalItemID);
    }

    return self;
}

- (void) portalDidLoad:(AGSPortal *)portal
{
    NSLog(@"Portal Loaded");
    self.portalItem = [[AGSPortalItem alloc] initWithPortal:portal itemId:self.portalItemID];
}

- (void) portal:(AGSPortal *)portal didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Could not load portal: %@", error);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Load the portal.
    NSLog(@"Creating Portal");
    self.view.layer.cornerRadius = 10;
    AGSPortal *p = [[AGSPortal alloc] initWithURL:[NSURL URLWithString:@"http://www.arcgis.com"] credential:nil];
    p.delegate = self;
    self.portal = p;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLabel:nil];
    [self setPortal:nil];
    [self setPortalItemID:nil];
    [self setPortalItem:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setPortalItem:(AGSPortalItem *)portalItem
{
    _portalItem = portalItem;
    _portalItem.delegate = self;
}

- (void)portalItemDidLoad:(AGSPortalItem *)portalItem
{
    [portalItem fetchData];
    [portalItem fetchThumbnail];
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchData:(NSData *)data
{
    NSLog(@"Loaded Portal Data");
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
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFailToFetchDataWithError:(NSError *)error
{
    NSLog(@"Failed to load portal item: %@", error);
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchThumbnail:(UIImage *)thumbnail
{
    self.imageView.image = thumbnail;
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFailToFetchThumbnailWithError:(NSError *)error
{
    NSLog(@"Failed to load thumbnail! %@", error.debugDescription);
}
- (IBAction)basemapTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BasemapSelected" object:self];
}
@end
