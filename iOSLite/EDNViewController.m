//
//  EDNViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNViewController.h"
#import	"AGSMapView+Navigation.h"
#import "AGSMapView+Basemaps.h"
#import "UILabel+EDNAutoSizeMutliline.h"

@interface EDNViewController () <AGSPortalItemDelegate, UIGestureRecognizerDelegate>
- (IBAction)nextMap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextBasemapButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) AGSPortalItem *currentPortalItem;
- (IBAction)infoRequested:(id)sender;
@end

@implementation EDNViewController
@synthesize nextBasemapButton = _nextBasemapButton;
@synthesize infoView = _infoView;
@synthesize infoImageView = _infoImageView;
@synthesize infoLabel = _infoLabel;
@synthesize infoButton = _infoButton;
@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;

EDNLiteBasemapType bmType = EDNLiteBasemapStreet;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapDidChange:) name:@"BasemapDidChange" object:self.mapView];
    
    [self.mapView setBasemap:bmType];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapDidLoad:) name:@"MapViewDidLoad" object:self.mapView];
    self.infoView.layer.cornerRadius = 13;
    self.infoImageView.layer.masksToBounds = YES;
    self.infoImageView.layer.cornerRadius = 8;
}

- (void)mapDidLoad:(NSNotification *)notification
{
    // Zoom to New York.
    [self.mapView zoomToLat:40.7302182289573 Long:-73.9958381652832 withScaleLevel:13];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapViewDidLoad" object:self.mapView];
}

- (void)basemapDidChange:(NSNotification *)notification
{
    NSNumber *basemapID = (NSNumber *)[notification.userInfo objectForKey:@"BasemapType"];
    EDNLiteBasemapType basemapType = (EDNLiteBasemapType)[basemapID intValue];
    NSString *basemapName = [EDNLiteHelper getBasemapName:basemapType];
    [self.nextBasemapButton setTitle:basemapName forState:UIControlStateNormal];
    [self.nextBasemapButton sizeToFit];
    
    AGSPortalItem *pi = [notification.userInfo objectForKey:@"PortalItem"];
    if (pi != nil)
    {
        self.currentPortalItem = pi;
        self.currentPortalItem.delegate = self;
        [self.currentPortalItem fetchData];
    }
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchData:(NSData *)data
{
    [UIView animateWithDuration:0.8
                     animations:^{
                         self.infoView.alpha = 1;
                     }];
	NSString *infoText = portalItem.title;
	
	if ([infoText componentsSeparatedByString:@" "].count == 1)
	{
		// If there's a single word, make sure we don't try to break it over two lines
		self.infoLabel.numberOfLines = 1;
	}
	else 
	{
		// Otherwise, we can drift over two lines if we want.
		self.infoLabel.numberOfLines = 2;
	}
    
	self.infoLabel.text = portalItem.title;
	[self.infoLabel setFontSizeToFit];
	
	if (self.infoImageView != nil)
	{
		[portalItem fetchThumbnail];
	}
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchThumbnail:(UIImage *)thumbnail
{
    self.infoImageView.image = thumbnail;
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFailToFetchThumbnailWithError:(NSError *)error
{
    NSLog(@"Failed to load thumbnail! %@", error.debugDescription);
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setNextBasemapButton:nil];
    [self setInfoView:nil];
    [self setInfoImageView:nil];
    [self setInfoLabel:nil];
    [self setInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)nextMap:(id)sender {
    if (bmType == EDNLiteBasemapOpenStreetMap)
    {
        bmType = EDNLiteBasemapStreet;
    }
    else {
        bmType += 1;
    }
    
    [self.mapView setBasemap:bmType];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.infoButton)
    {
        return NO;
    }
    return YES;
}

- (IBAction)infoRequested:(id)sender {
    if (self.currentPortalItem != nil)
    {
        NSString *url = [NSString stringWithFormat:@"http://www.arcgis.com/home/item.html?id=%@", self.currentPortalItem.itemId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
@end