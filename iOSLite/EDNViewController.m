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
#import "AGSMapView+Graphics.h"
#import "EDNBasemapDetailsViewController.h"
#import "UILabel+EDNAutoSizeMutliline.h"

@interface EDNViewController () <AGSPortalItemDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *nextBasemapButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (assign) EDNLiteBasemapType currentBasemapType;

- (IBAction)infoRequested:(id)sender;
- (IBAction)openBasemapSelector:(id)sender;
- (IBAction)nextMap:(id)sender;
- (IBAction)addGraphic:(id)sender;
@end

@implementation EDNViewController
@synthesize nextBasemapButton = _nextBasemapButton;
@synthesize infoView = _infoView;
@synthesize infoImageView = _infoImageView;
@synthesize infoLabel = _infoLabel;
@synthesize infoButton = _infoButton;
@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapDidChange:) name:@"BasemapDidChange" object:self.mapView];
    
    self.currentBasemapType = EDNLiteBasemapTopographic;
    
    self.infoView.layer.cornerRadius = 13;
    self.infoImageView.layer.masksToBounds = YES;
    self.infoImageView.layer.cornerRadius = 8;

    [self.mapView setBasemap:self.currentBasemapType];
    [self.mapView zoomToLat:40.7302 Long:-73.9958 withScaleLevel:13];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewDidLoad:) name:@"MapViewDidLoad" object:self.mapView];    
}

- (void)mapViewDidLoad:(NSNotification *)notification
{
    [self.mapView initGraphics];
}

- (void)basemapDidChange:(NSNotification *)notification
{
    AGSPortalItem *pi = [notification.userInfo objectForKey:@"PortalItem"];
    if (pi != nil)
    {
        self.currentPortalItem = pi;
        self.currentPortalItem.delegate = self;
        [self.currentPortalItem fetchData];
        [self.currentPortalItem fetchThumbnail];
    }
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchData:(NSData *)data
{
    if (self.infoView.alpha < 1)
    {
        [UIView animateWithDuration:0.8
                         animations:^{
                             self.infoView.alpha = 1;
                         }];
    }
    self.infoLabel.text = portalItem.title;
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

- (IBAction)nextMap:(id)sender
{
    // When the user clicks for the next map, we'll cycle through each map type and
    // update the map.
    if (self.currentBasemapType == EDNLiteBasemapLast)
    {
        self.currentBasemapType = EDNLiteBasemapFirst;
    }
    else {
        self.currentBasemapType += 1;
    }
    
    [self.mapView setBasemap:self.currentBasemapType];
}

- (IBAction)addGraphic:(id)sender {
    [self.mapView addPointAtLat:40.7302 Long:-73.9958];
    [self.mapView addLineWithLatsAndLongs:[NSNumber numberWithFloat:40.7302], [NSNumber numberWithFloat:-73.9958], 
                                          [NSNumber numberWithFloat:41.0], [NSNumber numberWithFloat:-73.9], nil];

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Make sure the gesture handler doesn't trap the button press too.
    if (touch.view == self.infoButton)
    {
        return NO;
    }
    return YES;
}

- (IBAction)infoRequested:(id)sender {
    // Seque to the Info Modal View.
    [self performSegueWithIdentifier:@"showBasemapInfo" sender:self];
}

- (IBAction)openBasemapSelector:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // If the Info Modal View is about to be shown, tell it what PortalItem we're showing.
    if ([segue.identifier isEqualToString:@"showBasemapInfo"])
    {
        EDNBasemapDetailsViewController *destVC = segue.destinationViewController;
        destVC.portalItem = self.currentPortalItem;
    }
}
@end