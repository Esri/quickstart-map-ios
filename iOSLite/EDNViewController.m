//
//  EDNViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNViewController.h"

#import "EDNLiteHelper.h"
#import	"AGSMapView+Navigation.h"
#import "AGSMapView+Basemaps.h"
#import "AGSMapView+Graphics.h"
#import "AGSMapView+Routing.h"

#import "EDNBasemapDetailsViewController.h"
#import "UILabel+EDNAutoSizeMutliline.h"

typedef enum 
{
    EDNVCStateBasemaps,
    EDNVCStateGeolocation,
    EDNVCStateGraphics,
    EDNVCStateFindPlace,
    EDNVCStateFindAddress,
    EDNVCStateDirections_WaitingForRouteStart,
    EDNVCStateDirections_WaitingForRouteStop
}
EDNVCState;

@interface EDNViewController () <AGSPortalItemDelegate, UIGestureRecognizerDelegate, AGSMapViewTouchDelegate, AGSRouteTaskDelegate>
// UI Properties
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicButton;

@property (weak, nonatomic) IBOutlet UIButton *clearPointsButton;
@property (weak, nonatomic) IBOutlet UIButton *clearLinesButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPolysButton;

@property (weak, nonatomic) IBOutlet UIView *routingPanel;
@property (weak, nonatomic) IBOutlet UILabel *routeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeStopLabel;
@property (nonatomic, strong) AGSPoint *routeStartPoint;
@property (nonatomic, strong) AGSPoint *routeStopPoint;
@property (weak, nonatomic) IBOutlet UIButton *solveRouteButton;
@property (weak, nonatomic) IBOutlet UILabel *findScaleLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *functionToolBar;

// Recognizers
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *infoTapRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *infoSwipeLeftRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *infoSwipeRightRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *uiTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *uiDoubleTapRecognizer;

// Non UI Properties
@property (assign) EDNLiteBasemapType currentBasemapType;
@property (assign) BOOL uiControlsVisible;

@property (assign) EDNVCState currentState;

@property (nonatomic, retain) AGSRouteTaskResult *routeResult;

@property (nonatomic, assign) NSUInteger findScale;

// Actions
- (IBAction)infoRequested:(id)sender;
- (IBAction)openBasemapSelector:(id)sender;
- (IBAction)previousMap:(id)sender;
- (IBAction)nextMap:(id)sender;
- (IBAction)addGraphic:(id)sender;
- (IBAction)uiTapped:(id)sender;

- (IBAction)clearPoints:(id)sender;
- (IBAction)clearLines:(id)sender;
- (IBAction)clearPolygons:(id)sender;

- (IBAction)toggleAutoRouting:(id)sender;
- (IBAction)solveRoute:(id)sender;
- (IBAction)selectRouteStart:(id)sender;
- (IBAction)selectRouteStop:(id)sender;

- (IBAction)findMe:(id)sender;
- (IBAction)findScaleChanged:(id)sender;
- (IBAction)zoomToLevel:(id)sender;

- (IBAction)functionChanged:(id)sender;
- (IBAction)basemapItemChanged:(id)sender;

@end

@implementation EDNViewController
@synthesize infoView = _infoView;
@synthesize infoImageView = _infoImageView;
@synthesize infoLabel = _infoLabel;
@synthesize infoButton = _infoButton;
@synthesize graphicButton = _graphicButton;
@synthesize clearPointsButton = _clearPointsButton;
@synthesize clearLinesButton = _clearLinesButton;
@synthesize clearPolysButton = _clearPolysButton;
@synthesize routingPanel = _routingPanel;
@synthesize routeStartLabel = _routeStartLabel;
@synthesize routeStopLabel = _routeStopLabel;
@synthesize infoTapRecognizer = _infoTapRecognizer;
@synthesize infoSwipeLeftRecognizer = _infoSwipeLeftRecognizer;
@synthesize infoSwipeRightRecognizer = _infoSwipeRightRecognizer;
@synthesize uiTapRecognizer = _uiTapRecognizer;
@synthesize uiDoubleTapRecognizer = _uiDoubleTapRecognizer;

@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

@synthesize uiControlsVisible = _uiControlsVisible;

@synthesize currentState = _currentState;

@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeStopPoint = _routeStopPoint;
@synthesize solveRouteButton = _solveRouteButton;
@synthesize findScaleLabel = _findScaleLabel;
@synthesize functionToolBar = _functionToolBar;

@synthesize routeResult = _routeResult;

@synthesize findScale = _findScale;

- (void)initUI
{
	// Track the application state (for now, used for routing input)
    self.currentState = EDNVCStateBasemaps;

    // We only want taps to be handled if the user doesn't double(ormore)-tap
    [self.uiTapRecognizer requireGestureRecognizerToFail:self.uiDoubleTapRecognizer];
    
    // Make some of the UI nice and comfy and round.
    self.infoView.layer.cornerRadius = 13;
    self.infoImageView.layer.masksToBounds = YES;
    self.infoImageView.layer.cornerRadius = 8;
    self.routingPanel.layer.cornerRadius = 8;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.findScale = 13;

    // And show the UI by default.
    self.uiControlsVisible = YES;


    // We want to update the UI when the basemap is changed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapDidChange:) name:@"BasemapDidChange" object:self.mapView];
    
    // Set up the map UI a little.
    self.mapView.wrapAround = YES;
    self.mapView.touchDelegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self initUI];

    // Initialize our property for tracking the current basemap type.
    self.currentBasemapType = EDNLiteBasemapTopographic;
    
	// Set up our map with a basemap, and jump to a location and scale level.
    [self.mapView setBasemap: self.currentBasemapType];
    [self.mapView centerAtLat:40.7302 Lng:-73.9958 withScaleLevel:13];
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    NSLog(@"Clicked on map!");
    switch (self.currentState) {
        case EDNVCStateDirections_WaitingForRouteStart:
            self.routeStartPoint = mappoint;
            break;
            
        case EDNVCStateDirections_WaitingForRouteStop:
            self.routeStopPoint = mappoint;
            break;
            
        default:
            NSLog(@"Click on %d graphics", graphics.count);
            for (id key in graphics.allKeys) {
                NSLog(@"Graphic '%@' = %@", key, [graphics objectForKey:key]);
            }
            break;
    }
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
    
    self.infoButton.userInteractionEnabled = YES;
    self.infoSwipeLeftRecognizer.enabled = YES;
    self.infoSwipeRightRecognizer.enabled = YES;
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchData:(NSData *)data
{
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
    [self setInfoView:nil];
    [self setInfoImageView:nil];
    [self setInfoLabel:nil];
    [self setInfoButton:nil];
    [self setUiTapRecognizer:nil];
    [self setInfoTapRecognizer:nil];
    [self setGraphicButton:nil];
    [self setUiDoubleTapRecognizer:nil];
    [self setClearPointsButton:nil];
    [self setClearLinesButton:nil];
    [self setClearPolysButton:nil];
    [self setRoutingPanel:nil];
    [self setRouteStartLabel:nil];
    [self setRouteStopLabel:nil];
    [self setSolveRouteButton:nil];
    [self setFindScaleLabel:nil];
    [self setInfoSwipeRightRecognizer:nil];
    [self setInfoSwipeLeftRecognizer:nil];
    [self setFunctionToolBar:nil];
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

    self.infoButton.userInteractionEnabled = NO;
    self.infoSwipeLeftRecognizer.enabled = NO;
    self.infoSwipeRightRecognizer.enabled = NO;

    [self.mapView setBasemap:self.currentBasemapType];
}

- (IBAction)previousMap:(id)sender {
    // When the user clicks for the next map, we'll cycle through each map type and
    // update the map.
    if (self.currentBasemapType == EDNLiteBasemapFirst)
    {
        self.currentBasemapType = EDNLiteBasemapLast;
    }
    else {
        self.currentBasemapType -= 1;
    }
    
    self.infoButton.userInteractionEnabled = NO;
    self.infoSwipeLeftRecognizer.enabled = NO;
    self.infoSwipeRightRecognizer.enabled = NO;
    
    [self.mapView setBasemap:self.currentBasemapType];
}

- (IBAction)addGraphic:(id)sender {
    [self.mapView addPointAtLat:40.7302 Lng:-73.9958];
    [self.mapView addLineWithLatsAndLngs:[NSNumber numberWithFloat:40.7302], [NSNumber numberWithFloat:-73.9958], 
                                          [NSNumber numberWithFloat:41.0], [NSNumber numberWithFloat:-73.9], nil];
    [self.mapView addPolygonWithLatsAndLngs:[NSNumber numberWithFloat:40.7302], [NSNumber numberWithFloat:-73.9958], 
     [NSNumber numberWithFloat:40.85], [NSNumber numberWithFloat:-73.65],
     [NSNumber numberWithFloat:41.0], [NSNumber numberWithFloat:-73.7],nil];
}

- (void)setFindScale:(NSUInteger)findScale
{
    _findScale = findScale;
    self.findScaleLabel.text = [NSString stringWithFormat:@"%d", _findScale];
}

- (void)setUIVisibility:(BOOL)visibility
{
    self.infoView.hidden = !visibility;
    self.graphicButton.hidden = !visibility;
//    self.statusView.hidden = !visibility;
    self.clearPointsButton.hidden = !visibility;
    self.clearLinesButton.hidden = !visibility;
    self.clearPolysButton.hidden = !visibility;
    self.routingPanel.hidden = !visibility;  
    self.functionToolBar.hidden = !visibility;
}

- (void)setUIAlpha:(double)targetAlpha
{
    self.infoView.alpha = targetAlpha;
    self.graphicButton.alpha = targetAlpha;
//    self.statusView.alpha = targetAlpha;
    self.clearPointsButton.alpha = targetAlpha;
    self.clearLinesButton.alpha = targetAlpha;
    self.clearPolysButton.alpha = targetAlpha;
    self.routingPanel.alpha = targetAlpha;
    self.functionToolBar.alpha = targetAlpha;
}

- (void)updateUIDisplayState
{
    float targetAlpha = self.uiControlsVisible?1:0;
    NSTimeInterval animationDuration = 0.85;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (self.uiControlsVisible)
    {
        // Unhide the controls and fade them into view.
        [self setUIVisibility:YES];
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [self setUIAlpha:targetAlpha];
                             self.wantsFullScreenLayout = NO;
                             [[UIApplication sharedApplication] setStatusBarHidden:NO];
                             UIScreen *mainScreen = [UIScreen mainScreen];
                             CGRect appFrame = mainScreen.applicationFrame;
                             NSLog(@"Dims: %f,%f %fx%f", appFrame.origin.x, appFrame.origin.y, appFrame.size.width, appFrame.size.height);
                             self.view.frame = appFrame;
                         }
                         completion:^(BOOL finished) {
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }];
    }
    else 
    {
        // Fade the controls out of view and hide them when done.
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [self setUIAlpha:targetAlpha];
                             self.wantsFullScreenLayout = YES;
                             [[UIApplication sharedApplication] setStatusBarHidden:YES];
                             UIScreen *mainScreen = [UIScreen mainScreen];
                             CGRect appFrame = mainScreen.applicationFrame;
                             NSLog(@"Dims: %f,%f %fx%f", appFrame.origin.x, appFrame.origin.y, appFrame.size.width, appFrame.size.height);
                             self.view.frame = appFrame;
                         }
                         completion:^(BOOL finished) {
                             [self setUIVisibility:NO];
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }];
    }
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
    if ((gestureRecognizer == self.infoTapRecognizer ||
         gestureRecognizer == self.infoSwipeLeftRecognizer ||
         gestureRecognizer == self.infoSwipeRightRecognizer) &&
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

- (EDNVCState)currentState
{
    return _currentState;
}

- (void) setCurrentState:(EDNVCState)currentState
{
    _currentState = currentState;
    
    switch (_currentState) {
        case EDNVCStateDirections_WaitingForRouteStart:
            self.routeStartLabel.text = @"Tap a point on the map…";
            self.uiTapRecognizer.enabled = NO;
            self.uiDoubleTapRecognizer.enabled = NO;
            break;
        case EDNVCStateDirections_WaitingForRouteStop:
            self.routeStopLabel.text = @"Tap a point on the map…";
            self.uiTapRecognizer.enabled = NO;
            self.uiDoubleTapRecognizer.enabled = NO;
            break;
            
        default:
            self.uiTapRecognizer.enabled = YES;
            self.uiDoubleTapRecognizer.enabled = YES;
            break;
    }
}

- (BOOL) doAutoRoute
{
    if (!self.solveRouteButton.enabled)
    {
        NSLog(@"Automatically solving route");
        return [self doRouteIfPossible];
    }
    return NO;
}

- (BOOL) doRouteIfPossible
{
    if (self.routeStartPoint &&
        self.routeStopPoint)
    {
        NSLog(@"Start and stop points set...");
        [self.mapView getDirectionsFromPoint:self.routeStartPoint ToPoint:self.routeStopPoint WithHandler:self];
        self.uiControlsVisible = NO;
        return YES;
    }
    return NO;
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
    self.routeResult = routeTaskResult;
    self.solveRouteButton.enabled = YES;
}

- (void) setRouteStartPoint:(AGSPoint *)routeStartPoint
{
    _routeStartPoint = routeStartPoint;
    if (_routeStartPoint)
    {
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromWebMercatorAuxSpherePoint:_routeStartPoint];
        self.routeStartLabel.text = [NSString stringWithFormat:@"(%.4f,%.4f)", wgs84Pt.y, wgs84Pt.x];
        if ([self doAutoRoute])
        {
            self.currentState = EDNVCStateBasemaps;
        }
        else if (!self.solveRouteButton.enabled)
        {
            self.currentState = EDNVCStateDirections_WaitingForRouteStart;
        }
        else {
            self.currentState = EDNVCStateBasemaps;
        }
    }
    else {
        self.routeStartLabel.text = @"Tap to the right…";
    }
}

- (void) setRouteStopPoint:(AGSPoint *)routeStopPoint
{
    _routeStopPoint = routeStopPoint;
    self.currentState = EDNVCStateBasemaps;
    if (_routeStopPoint)
    {
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromWebMercatorAuxSpherePoint:_routeStopPoint];
        self.routeStopLabel.text = [NSString stringWithFormat:@"(%.4f,%.4f)", wgs84Pt.y, wgs84Pt.x];
        if ([self doAutoRoute])
        {
            self.currentState = EDNVCStateBasemaps;
        }
        else if (!self.solveRouteButton.enabled)
        {
            self.currentState = EDNVCStateDirections_WaitingForRouteStart;
        }
        else {
            self.currentState = EDNVCStateBasemaps;
        }
    }
    else {
        self.routeStopLabel.text = @"Tap to the right…";
    }
}

- (IBAction)toggleAutoRouting:(id)sender {
    UISegmentedControl *autoRouting = sender;
    if (autoRouting.selectedSegmentIndex == 0) {
        // Manual
        self.solveRouteButton.enabled = YES;
    }
    else {
        // Auto
        self.solveRouteButton.enabled = NO;
        self.routeStartPoint = nil;
        self.routeStopPoint = nil;
        self.currentState = EDNVCStateDirections_WaitingForRouteStart;
    }
}

- (IBAction)solveRoute:(id)sender {
    if (self.routeResult)
    {
        self.routeResult = nil;
        [self.mapView clearRoute];
        self.solveRouteButton.enabled = NO;
        self.routeStartPoint = nil;
        self.routeStopPoint = nil;
        self.currentState = EDNVCStateDirections_WaitingForRouteStart;
    }
}

- (IBAction)selectRouteStart:(id)sender {
    if (self.currentState != EDNVCStateDirections_WaitingForRouteStart)
    {
        self.currentState = EDNVCStateDirections_WaitingForRouteStart;
    }
    else {
        self.currentState = EDNVCStateBasemaps;
    }
}

- (IBAction)selectRouteStop:(id)sender {
    if (self.currentState != EDNVCStateDirections_WaitingForRouteStop)
    {
        self.currentState = EDNVCStateDirections_WaitingForRouteStop;
    }
    else {
        self.currentState = EDNVCStateBasemaps;
    }
}

- (IBAction)findMe:(id)sender {
	[self.mapView centerAtMyLocationWithScaleLevel:self.findScale];
}

- (IBAction)findScaleChanged:(id)sender {
    UISlider *slider = sender;
    self.findScale = (NSUInteger)roundf(slider.value);
}

- (IBAction)zoomToLevel:(id)sender {
    [self.mapView zoomToLevel:self.findScale];
}

- (IBAction)functionChanged:(id)sender {
}

- (IBAction)basemapItemChanged:(id)sender {
}
@end