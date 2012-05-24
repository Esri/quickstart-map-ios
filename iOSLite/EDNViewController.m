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
// UI Properties
@property (weak, nonatomic) IBOutlet UIButton *nextBasemapButton;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicButton;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *clearPointsButton;
@property (weak, nonatomic) IBOutlet UIButton *clearLinesButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPolysButton;

// Recognizers
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *infoTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *uiTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *uiDoubleTapRecognizer;

// Non UI Properties
@property (assign) EDNLiteBasemapType currentBasemapType;
@property (assign) BOOL uiControlsVisible;

// Actions
- (IBAction)infoRequested:(id)sender;
- (IBAction)openBasemapSelector:(id)sender;
- (IBAction)nextMap:(id)sender;
- (IBAction)addGraphic:(id)sender;
- (IBAction)uiTapped:(id)sender;
- (IBAction)doubleTapped:(id)sender;

- (IBAction)clearPoints:(id)sender;
- (IBAction)clearLines:(id)sender;
- (IBAction)clearPolygons:(id)sender;
@end

@implementation EDNViewController
@synthesize nextBasemapButton = _nextBasemapButton;
@synthesize infoView = _infoView;
@synthesize infoImageView = _infoImageView;
@synthesize infoLabel = _infoLabel;
@synthesize infoButton = _infoButton;
@synthesize graphicButton = _graphicButton;
@synthesize statusView = _statusView;
@synthesize statusLabel = _statusLabel;
@synthesize clearPointsButton = _clearPointsButton;
@synthesize clearLinesButton = _clearLinesButton;
@synthesize clearPolysButton = _clearPolysButton;
@synthesize infoTapRecognizer = _infoTapRecognizer;
@synthesize uiTapRecognizer = _uiTapRecognizer;
@synthesize uiDoubleTapRecognizer = _uiDoubleTapRecognizer;

@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

@synthesize uiControlsVisible = _uiControlsVisible;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    
    // We only want taps to be handled if the user doesn't double(ormore)-tap
    [self.uiTapRecognizer requireGestureRecognizerToFail:self.uiDoubleTapRecognizer];
    
    // We want to update the UI when the basemap is changed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapDidChange:) name:@"BasemapDidChange" object:self.mapView];
    
    // Initialize our property for tracking the current basemap type.
    self.currentBasemapType = EDNLiteBasemapTopographic;
    
    // Make some of the UI nice and comfy and round.
    self.infoView.layer.cornerRadius = 13;
    self.statusView.layer.cornerRadius = 13;
    self.infoImageView.layer.masksToBounds = YES;
    self.infoImageView.layer.cornerRadius = 8;

    // Set up the map and zoom in.
    self.mapView.wrapAround = YES;
    [self.mapView setBasemap:self.currentBasemapType];
    [self.mapView zoomToLat:40.7302 Long:-73.9958 withScaleLevel:13];

    // And show the UI by default.
    self.uiControlsVisible = YES;
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
//    if (self.infoView.alpha < 1)
//    {
//        [UIView animateWithDuration:0.8
//                         animations:^{
//                             self.infoView.alpha = 1;
//                         }];
//    }
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
    [self setUiTapRecognizer:nil];
    [self setInfoTapRecognizer:nil];
    [self setGraphicButton:nil];
    [self setUiDoubleTapRecognizer:nil];
    [self setStatusView:nil];
    [self setStatusLabel:nil];
    [self setClearPointsButton:nil];
    [self setClearLinesButton:nil];
    [self setClearPolysButton:nil];
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
    [self.mapView addPolygonWithLatsAndLongs:[NSNumber numberWithFloat:40.7302], [NSNumber numberWithFloat:-73.9958], 
     [NSNumber numberWithFloat:40.85], [NSNumber numberWithFloat:-73.65],
     [NSNumber numberWithFloat:41.0], [NSNumber numberWithFloat:-73.7],nil];

}

- (void)updateUIDisplayState
{
    [UIView animateWithDuration:0.85
                     animations:^{
                         float targetAlpha = self.uiControlsVisible?1:0;

                         if (self.uiControlsVisible)
                         {
                             self.infoView.hidden = NO;
                             self.graphicButton.hidden = NO;
                             self.statusView.hidden = NO;
                             self.clearPointsButton.hidden = NO;
                             self.clearLinesButton.hidden = NO;
                             self.clearPolysButton.hidden = NO;
                         }
                         self.infoView.alpha = targetAlpha;
                         self.graphicButton.alpha = targetAlpha;
                         self.statusView.alpha = targetAlpha;
                         self.clearPointsButton.alpha = targetAlpha;
                         self.clearLinesButton.alpha = targetAlpha;
                         self.clearPolysButton.alpha = targetAlpha;
                     }
                     completion:^(BOOL finished) {
                         self.infoView.hidden = !self.uiControlsVisible;
                         self.graphicButton.hidden = !self.uiControlsVisible;
                         self.statusView.hidden = !self.uiControlsVisible;
                         self.clearPointsButton.hidden = !self.uiControlsVisible;
                         self.clearLinesButton.hidden = !self.uiControlsVisible;
                         self.clearPolysButton.hidden = !self.uiControlsVisible;
                     }];
}

- (BOOL)uiControlsVisible
{
    return _uiControlsVisible;
}

- (void)setUiControlsVisible:(BOOL)uiControlsVisible
{
    _uiControlsVisible = uiControlsVisible;
    [self updateUIDisplayState];
}

- (IBAction)uiTapped:(id)sender {
    self.uiControlsVisible = !self.uiControlsVisible;
}

- (IBAction)doubleTapped:(id)sender {
}

- (IBAction)clearPoints:(id)sender {
    [self.mapView clearGraphics:EDNLiteGraphicsLayerTypePoint];
}

- (IBAction)clearLines:(id)sender {
    [self.mapView clearGraphics:EDNLiteGraphicsLayerTypePolyline];
}

- (IBAction)clearPolygons:(id)sender {
    [self.mapView clearGraphics:EDNLiteGraphicsLayerTypePolygon];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Make sure the gesture handler doesn't trap the button press too.
    if (gestureRecognizer == self.infoTapRecognizer &&
        touch.view == self.infoButton)
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