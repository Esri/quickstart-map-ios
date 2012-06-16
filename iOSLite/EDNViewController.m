//
//  EDNViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNViewController.h"
#import "EDNBasemapsListView.h"
#import "EDNBasemapItemViewController.h"

#import "EDNLiteHelper.h"
#import	"AGSMapView+Navigation.h"
#import "AGSMapView+Basemaps.h"
#import "AGSMapView+Graphics.h"
#import "AGSMapView+Routing.h"
#import "AGSMapView+Geocoding.h"

#import "EDNBasemapDetailsViewController.h"
#import "UILabel+EDNAutoSizeMutliline.h"
#import "/usr/include/objc/runtime.h"

typedef enum 
{
    EDNVCStateBasemaps,
    EDNVCStateGeolocation,
    EDNVCStateGraphics,
    EDNVCStateGraphics_Editing,
    EDNVCStateFindPlace,
    EDNVCStateFindAddress,
	EDNVCStateDirections,
    EDNVCStateDirections_WaitingForRouteStart,
    EDNVCStateDirections_WaitingForRouteStop
}
EDNVCState;

@interface EDNViewController () <AGSPortalItemDelegate, AGSMapViewTouchDelegate, AGSRouteTaskDelegate, UISearchBarDelegate, AGSLocatorDelegate, UIWebViewDelegate>

// General UI
@property (weak, nonatomic) IBOutlet UIToolbar *functionToolBar;
@property (weak, nonatomic) IBOutlet UIView *routingPanel;
@property (weak, nonatomic) IBOutlet UIView *findAddressPanel;
@property (weak, nonatomic) IBOutlet UIView *findPlacePanel;
@property (weak, nonatomic) IBOutlet UIView *basemapInfoPanel;
@property (weak, nonatomic) IBOutlet UIView *geolocationPanel;
@property (weak, nonatomic) IBOutlet UIView *graphicsPanel;

// Basemaps
@property (weak, nonatomic) IBOutlet UIImageView *currentBasemapImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentBasemapNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *currentBasemapMoreInfoButton;
@property (weak, nonatomic) IBOutlet EDNBasemapsListView *basemapListDisplay;
@property (weak, nonatomic) IBOutlet UIWebView *currentBasemapDescriptionWebView;

@property (strong, nonatomic) NSMutableArray *basemapVCs;

//Graphics UI
@property (weak, nonatomic) IBOutlet UIButton *graphicButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPointsButton;
@property (weak, nonatomic) IBOutlet UIButton *clearLinesButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPolysButton;
// Edit Graphics UI
@property (weak, nonatomic) IBOutlet UIToolbar *editGraphicsToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoEditGraphicsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoEditGraphicsButton;
- (IBAction)doneEditingGraphic:(id)sender;
- (IBAction)cancelEditingGraphic:(id)sender;
- (IBAction)undoEditingGraphic:(id)sender;
- (IBAction)redoEditingGraphic:(id)sender;
- (IBAction)zoomToEditingGeometry:(id)sender;


// Routing UI
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fromLocationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *routeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeStopLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *routeStartSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *routeStopSearchBar;
// Routing Properties
@property (nonatomic, strong) AGSPoint *routeStartPoint;
@property (nonatomic, strong) AGSPoint *routeStopPoint;

// Geolocation UI
@property (weak, nonatomic) IBOutlet UILabel *findScaleLabel;

// Non UI Properties
@property (assign) EDNLiteBasemapType currentBasemapType;
@property (assign) BOOL uiControlsVisible;

@property (assign) EDNVCState currentState;

@property (nonatomic, retain) AGSRouteTaskResult *routeResult;

@property (nonatomic, assign) NSUInteger findScale;

// Actions
- (IBAction)infoRequested:(id)sender;
- (IBAction)addGraphic:(id)sender;

- (IBAction)clearPoints:(id)sender;
- (IBAction)clearLines:(id)sender;
- (IBAction)clearPolygons:(id)sender;

- (IBAction)clearRoute:(id)sender;

- (IBAction)findMe:(id)sender;
- (IBAction)findScaleChanged:(id)sender;
- (IBAction)zoomToLevel:(id)sender;

- (IBAction)functionChanged:(id)sender;

- (IBAction)toFromTapped:(id)sender;
@end

@implementation EDNViewController
@synthesize editGraphicsToolbar = _editGraphicsToolbar;
@synthesize undoEditGraphicsButton = _undoEditGraphicsButton;
@synthesize redoEditGraphicsButton = _redoEditGraphicsButton;
@synthesize basemapInfoPanel = _infoView;
@synthesize geolocationPanel = _geolocationPanel;
@synthesize graphicsPanel = _graphicsPanel;
@synthesize currentBasemapImageView = _infoImageView;
@synthesize currentBasemapNameLabel = _infoLabel;
@synthesize currentBasemapMoreInfoButton = _infoButton;
@synthesize basemapListDisplay = _basemapListDisplay;
@synthesize currentBasemapDescriptionWebView = _currentBasemapDescriptionWebView;
@synthesize graphicButton = _graphicButton;
@synthesize clearPointsButton = _clearPointsButton;
@synthesize clearLinesButton = _clearLinesButton;
@synthesize clearPolysButton = _clearPolysButton;
@synthesize routingPanel = _routingPanel;
@synthesize findAddressPanel = _findAddressPanel;
@synthesize findPlacePanel = _findPlacePanel;
@synthesize routeStartLabel = _routeStartLabel;
@synthesize routeStopLabel = _routeStopLabel;
@synthesize routeStartSearchBar = _routeStartSearchBar;
@synthesize routeStopSearchBar = _routeStopSearchBar;

@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

@synthesize uiControlsVisible = _uiControlsVisible;

@synthesize currentState = _currentState;

@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeStopPoint = _routeStopPoint;
@synthesize findScaleLabel = _findScaleLabel;
@synthesize functionToolBar = _functionToolBar;
@synthesize fromLocationButton = _fromLocationButton;
@synthesize toLocationButton = _toLocationButton;

@synthesize routeResult = _routeResult;

@synthesize findScale = _findScale;

@synthesize basemapVCs = _basemapVCs;

#define kEDNLiteApplicationLocFromState @"ButtonState"

- (void)initUI
{
	// Track the application state (for now, used for routing input)
    self.currentState = EDNVCStateBasemaps;

    objc_setAssociatedObject(self.fromLocationButton, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self.toLocationButton, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];

    self.findScale = 13;
    
    for (UIView *v in [self allUIViews]) {
        v.alpha = 0;
        v.hidden = YES;
        v.frame = [self getUIFrameWhenHidden:v];
    }

    // And show the UI by default.
    self.uiControlsVisible = YES;

    // We want to update the UI when the basemap is changed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapDidChange:) name:@"BasemapDidChange" object:self.mapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapSelected:) name:@"BasemapSelected" object:nil];

    // Set up the map UI a little.
    self.mapView.wrapAround = YES;
    self.mapView.touchDelegate = self;
}

- (CGPoint) getUIComponentOrigin
{
    CGRect topFrame = self.functionToolBar.frame;
    CGPoint newOrigin = CGPointMake(topFrame.origin.x, topFrame.origin.y + topFrame.size.height);
    return newOrigin;
}

- (CGRect) getUIFrame:(UIView *)viewToDisplay
{
    CGPoint origin = [self getUIComponentOrigin];
    CGRect viewFrame = viewToDisplay.frame;
    CGRect newFrame = CGRectMake(origin.x, origin.y, viewFrame.size.width, viewFrame.size.height);
    return newFrame;
}

- (CGRect) getUIFrameWhenHidden:(UIView *)viewToHide
{
    CGPoint origin = [self getUIComponentOrigin];
    CGSize viewSize = viewToHide.frame.size;
    // Position it to the left of the screen.
    CGRect newFrame = CGRectMake(origin.x, origin.y - viewSize.height, viewSize.width, viewSize.height);
    return newFrame;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"KeyPath: %@", keyPath);
}

- (void) setUndoRedoButtonStatesForUndoManager:(NSUndoManager *)um
{
    if (um)
    {
        self.undoEditGraphicsButton.enabled = um.canUndo;
        self.redoEditGraphicsButton.enabled = um.canRedo;
    }
}

- (void) setUndoRedoButtonStates
{
    [self setUndoRedoButtonStatesForUndoManager:[self.mapView getUndoManagerForGraphicsEdits]];
}

- (void) editUndoRedoChanged:(NSNotification *)notification
{
    NSUndoManager *um = notification.object;
    [self setUndoRedoButtonStatesForUndoManager:um];
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    NSLog(@"Clicked on map!");
    switch (self.currentState) {
        case EDNVCStateGraphics:
            if (graphics.count > 0)
            {
                // The user selected a graphic. Let's edit it.
                [self.mapView editGraphicFromDidClickAtPointEvent:graphics];
                NSUndoManager *um = [self.mapView getUndoManagerForGraphicsEdits];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(editUndoRedoChanged:)
                                                             name:@"NSUndoManagerDidCloseUndoGroupNotification"
                                                           object:um];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(editUndoRedoChanged:)
                                                             name:@"NSUndoManagerDidUndoChangeNotification"
                                                           object:um];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(editUndoRedoChanged:)
                                                             name:@"NSUndoManagerDidRedoChangeNotification"
                                                           object:um];
                self.currentState = EDNVCStateGraphics_Editing;
            }
            break;
        case EDNVCStateDirections_WaitingForRouteStart:
            self.routeStartPoint = mappoint;
            break;
            
        case EDNVCStateDirections_WaitingForRouteStop:
            self.routeStopPoint = mappoint;
            break;
            
        case EDNVCStateFindAddress:
            [self.mapView getAddressForMapPoint:mappoint];
            break;
            
        default:
            NSLog(@"Click on %d graphics", graphics.count);
            for (id key in graphics.allKeys) {
                NSLog(@"Graphic '%@' = %@", key, [graphics objectForKey:key]);
            }
            break;
    }
}

- (void)basemapSelected:(NSNotification *)notification
{
    EDNBasemapItemViewController *bvc = notification.object;
    if (bvc)
    {
        if (bvc.basemapType != self.currentBasemapType)
        {
            [self.mapView setBasemap:bvc.basemapType];
        }
    }
}

- (void)setCurrentPortalItem:(AGSPortalItem *)currentPortalItem
{
    _currentPortalItem = currentPortalItem;
    
    self.currentBasemapNameLabel.text = _currentPortalItem.title;
    //self.currentBasemapDescriptionTextView.text = _currentPortalItem.itemDescription;
    NSString *filePath = [[NSBundle mainBundle] resourcePath];
    NSLog(@"FilePath: %@", filePath);
    NSURL *baseURL = [NSURL fileURLWithPath:filePath isDirectory:YES];
    NSString *htmlToShow = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"description.css\" /></head><body>%@</body></html>", _currentPortalItem.snippet];
    [self.currentBasemapDescriptionWebView loadHTMLString:htmlToShow baseURL:baseURL];

    _currentPortalItem.delegate = self;
//    [_currentPortalItem fetchData];
    [_currentPortalItem fetchThumbnail];
}

- (EDNLiteBasemapType)currentBasemapType
{
    return _currentBasemapType;
}

- (void)setCurrentBasemapType:(EDNLiteBasemapType)currentBasemapType
{
    _currentBasemapType = currentBasemapType;
    [self.basemapListDisplay ensureItemVisible:_currentBasemapType Highlighted:YES];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)portalItem:(AGSPortalItem *)portalItem operation:(NSOperation *)op didFetchThumbnail:(UIImage *)thumbnail
{
    self.currentBasemapImageView.image = thumbnail;
}

- (void)basemapDidChange:(NSNotification *)notification
{
    AGSPortalItem *pi = [notification.userInfo objectForKey:@"PortalItem"];
    EDNLiteBasemapType basemapType = [(NSNumber *)[notification.userInfo objectForKey:@"BasemapType"] intValue];
    self.currentBasemapType = basemapType;
    if (pi)
    {
        self.currentPortalItem = pi;
    }
    
    self.currentBasemapMoreInfoButton.userInteractionEnabled = YES;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setBasemapInfoPanel:nil];
    [self setCurrentBasemapImageView:nil];
    [self setCurrentBasemapNameLabel:nil];
    [self setCurrentBasemapMoreInfoButton:nil];
    [self setGraphicButton:nil];
    [self setClearPointsButton:nil];
    [self setClearLinesButton:nil];
    [self setClearPolysButton:nil];
    [self setRoutingPanel:nil];
    [self setRouteStartLabel:nil];
    [self setRouteStopLabel:nil];
    [self setFindScaleLabel:nil];
    [self setFunctionToolBar:nil];
    [self setFromLocationButton:nil];
    [self setToLocationButton:nil];
    [self setFindAddressPanel:nil];
    [self setFindPlacePanel:nil];
    [self setGeolocationPanel:nil];
    [self setGraphicsPanel:nil];
    [self setRouteStartSearchBar:nil];
    [self setRouteStopSearchBar:nil];
    [self setBasemapListDisplay:nil];
    [self setCurrentBasemapDescriptionWebView:nil];
    [self setEditGraphicsToolbar:nil];
    [self setUndoEditGraphicsButton:nil];
    [self setRedoEditGraphicsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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

- (NSMutableArray *)allUIViews
{
    NSMutableArray *uiViews = [NSMutableArray arrayWithObjects:self.routingPanel,
                               self.basemapInfoPanel,
                               self.geolocationPanel,
                               self.findAddressPanel,
                               self.findPlacePanel,
                               self.graphicsPanel, nil];
    return uiViews;
}

- (UIView *) getViewToShow
{
    UIView *viewToShow = nil;
    
    switch (self.currentState) {
        case EDNVCStateBasemaps:
            viewToShow = self.basemapInfoPanel;
            break;
        case EDNVCStateDirections:
        case EDNVCStateDirections_WaitingForRouteStart:
        case EDNVCStateDirections_WaitingForRouteStop:
            viewToShow = self.routingPanel;
            break;
        case EDNVCStateFindAddress:
            viewToShow = self.findAddressPanel;
            break;
        case EDNVCStateFindPlace:
            viewToShow = self.findPlacePanel;
            break;
        case EDNVCStateGeolocation:
            viewToShow = self.geolocationPanel;
            break;
        case EDNVCStateGraphics:
        case EDNVCStateGraphics_Editing:
            viewToShow = self.graphicsPanel;
            break;
    }
    
    return viewToShow;
}

- (NSArray *) getViewsToHide
{
    NSMutableArray *views = [self allUIViews];
    UIView *viewToDisplay = [self getViewToShow];
    [views removeObject:viewToDisplay];
    return views;
}

- (void)setUIVisibility:(BOOL)visibility
{
    // Always deal with the function toolbar.
//    self.functionToolBar.hidden = !visibility;
    
    // Then what's visible depends on the current application state.
    for (UIView *viewToHide in [self getViewsToHide]) {
        viewToHide.hidden = YES;
        viewToHide.frame = [self getUIFrameWhenHidden:viewToHide];
    }
 
    UIView *viewToShow = [self getViewToShow];
    viewToShow.frame = [self getUIFrame:viewToShow];
    viewToShow.hidden = !visibility;
}

- (void)setUIAlpha:(double)targetAlpha
{
    // Always deal with the function toolbar.
    self.functionToolBar.alpha = targetAlpha;

    self.basemapInfoPanel.alpha = targetAlpha;
    self.graphicButton.alpha = targetAlpha;
    self.clearPointsButton.alpha = targetAlpha;
    self.clearLinesButton.alpha = targetAlpha;
    self.clearPolysButton.alpha = targetAlpha;
    self.routingPanel.alpha = targetAlpha;
}

- (void)updateUIDisplayState
{
    NSTimeInterval animationDuration = 0.4;
    UIView *viewToShow = [self getViewToShow];
    NSArray *viewsToHide = [self getViewsToHide];

    // If the view is already visible, then we don't need to update...
    BOOL needToChange = YES;//viewToShow.hidden == NO;
    
    if (needToChange)
    {
        // Animate out the old views and animate in the new view
        UIView *viewToAnimateOut = nil;
        
        for (UIView *viewCandidate in viewsToHide) {
            if (!viewCandidate.hidden)
            {
                viewToAnimateOut = viewCandidate;
                break;
            }
        }
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        viewToShow.hidden = NO;
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             viewToShow.alpha = 1;
                             viewToAnimateOut.alpha = 0;
                             viewToShow.frame = [self getUIFrame:viewToShow];
                             viewToAnimateOut.frame = [self getUIFrameWhenHidden:viewToAnimateOut];
                         }
                         completion:^(BOOL finished) {
                             viewToAnimateOut.hidden = YES;
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

- (IBAction)clearPoints:(id)sender {
    [self.mapView clearGraphics:EDNLiteGraphicsLayerTypePoint];
}

- (IBAction)clearLines:(id)sender {
    [self.mapView clearGraphics:EDNLiteGraphicsLayerTypePolyline];
}

- (IBAction)clearPolygons:(id)sender {
    [self.mapView clearGraphics:EDNLiteGraphicsLayerTypePolygon];
}

- (IBAction)infoRequested:(id)sender {
    // Seque to the Info Modal View.
    [self performSegueWithIdentifier:@"showBasemapInfo" sender:self];
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
            break;
        case EDNVCStateDirections_WaitingForRouteStop:
            self.routeStopLabel.text = @"Tap a point on the map…";
            break;
            
        case EDNVCStateGraphics_Editing:
            for (UIBarButtonItem *buttonItem in self.editGraphicsToolbar.items) {
                buttonItem.enabled = YES;
            }
            [self setUndoRedoButtonStates];
            self.mapView.showMagnifierOnTapAndHold = YES;
            break;
        case EDNVCStateGraphics:
            for (UIBarButtonItem *buttonItem in self.editGraphicsToolbar.items) {
                buttonItem.enabled = NO;
            }
            self.mapView.showMagnifierOnTapAndHold = NO;
            break;
            
        default:
            break;
    }
    
    [self updateUIDisplayState];
}

- (BOOL) doRouteIfPossible
{
    if (self.routeStartPoint &&
        self.routeStopPoint)
    {
        NSLog(@"Start and stop points set...");
        [self.mapView getDirectionsFromPoint:self.routeStartPoint ToPoint:self.routeStopPoint WithDelegate:self];
//        self.uiControlsVisible = NO;
        return YES;
    }
    return NO;
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
    self.routeResult = routeTaskResult;
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{
    NSDictionary *ad = candidate.address;
    NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@",
                         [ad objectForKey:@"Address"],
                         [ad objectForKey:@"City"],
                         [ad objectForKey:@"State"],
                         [ad objectForKey:@"Zip"]];
    NSString *source = objc_getAssociatedObject(op, @"SOURCE");
    if (source)
    {
        if ([source isEqualToString:@"START"])
        {
            self.routeStartSearchBar.text = address;
        }
        else if ([source isEqualToString:@"STOP"])
        {
            self.routeStopSearchBar.text = address;
        }
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
    NSLog(@"Failed to get address for location: %@", error);
}

- (void) setRouteStartPoint:(AGSPoint *)routeStartPoint
{
    _routeStartPoint = routeStartPoint;
    if (_routeStartPoint)
    {
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromWebMercatorAuxSpherePoint:_routeStartPoint];
        self.routeStartLabel.text = [NSString stringWithFormat:@"(%.4f,%.4f)", wgs84Pt.y, wgs84Pt.x];
		self.currentState = EDNVCStateDirections;
        [self setToFromButton:self.fromLocationButton selectedState:NO];
        NSOperation *op = [self.mapView getAddressForMapPoint:wgs84Pt withDelegate:self];
        objc_setAssociatedObject(op, @"SOURCE", @"START", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self doRouteIfPossible];
    }
}

- (void) setRouteStopPoint:(AGSPoint *)routeStopPoint
{
    _routeStopPoint = routeStopPoint;
//    self.currentState = EDNVCStateBasemaps;
    if (_routeStopPoint)
    {
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromWebMercatorAuxSpherePoint:_routeStopPoint];
        self.routeStopLabel.text = [NSString stringWithFormat:@"(%.4f,%.4f)", wgs84Pt.y, wgs84Pt.x];
		self.currentState = EDNVCStateDirections;
        [self setToFromButton:self.toLocationButton selectedState:NO];
        NSOperation *op = [self.mapView getAddressForMapPoint:wgs84Pt withDelegate:self];
        objc_setAssociatedObject(op, @"SOURCE", @"STOP", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self doRouteIfPossible];
	}
}

- (IBAction)clearRoute:(id)sender {
    if (self.routeResult)
    {
        self.routeResult = nil;
        [self.mapView clearRoute];
        self.routeStartPoint = nil;
        self.routeStopPoint = nil;
        self.currentState = EDNVCStateDirections_WaitingForRouteStart;
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
    UISegmentedControl *seg = sender;
    switch (seg.selectedSegmentIndex) {
        case 0:
            self.currentState = EDNVCStateBasemaps;
            break;
        case 1:
            self.currentState = EDNVCStateGeolocation;
            break;
        case 2:
            self.currentState = EDNVCStateGraphics;
            break;
        case 3:
            self.currentState = EDNVCStateFindPlace;
            break;
        case 4:
            self.currentState = EDNVCStateFindAddress;
            break;
        case 5:
            self.currentState = EDNVCStateDirections;
            break;
        default:
            NSLog(@"Set state to %d", seg.selectedSegmentIndex);
            break;
    }
}

- (void)setToFromButton:(UIBarButtonItem *)bi selectedState:(BOOL)selected
{
    // Clear the other button regardless of the new state for this one.
    UIBarButtonItem *otherBi = (bi == self.fromLocationButton)?self.toLocationButton:self.fromLocationButton;
    otherBi.tintColor = nil;
    objc_setAssociatedObject(otherBi, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Set the new state for this one, and set our app state too.
    NSLog(@"Selected: %@", selected?@"YES":@"NO");
    if (selected)
    {
        bi.tintColor = [UIColor colorWithWhite:0.6 alpha:1];
        self.currentState = (bi == self.fromLocationButton)?EDNVCStateDirections_WaitingForRouteStart:EDNVCStateDirections_WaitingForRouteStop;
    }
    else
    {
        bi.tintColor = nil;
        self.currentState = EDNVCStateDirections;
    }
    objc_setAssociatedObject(bi, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:selected], OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

- (IBAction)toFromTapped:(id)sender {
    BOOL selected = [(NSNumber *)objc_getAssociatedObject(sender, kEDNLiteApplicationLocFromState) boolValue];
    [self setToFromButton:sender selectedState:!selected];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *searchString = searchBar.text;
	NSLog(@"Searching for: %@", searchString);
	[self.mapView findAddress:searchString];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
- (IBAction)doneEditingGraphic:(id)sender {
    [self.mapView saveCurrentEdit];
    self.currentState = EDNVCStateGraphics;
}

- (IBAction)cancelEditingGraphic:(id)sender {
    [self.mapView cancelCurrentEdit];
    self.currentState = EDNVCStateGraphics;
}

- (IBAction)undoEditingGraphic:(id)sender {
    [[self.mapView getUndoManagerForGraphicsEdits] undo];
}

- (IBAction)redoEditingGraphic:(id)sender {
    [[self.mapView getUndoManagerForGraphicsEdits] redo];
}

- (IBAction)zoomToEditingGeometry:(id)sender {
    AGSGeometry *editGeom = [self.mapView getCurrentEditGeometry];
    if (editGeom)
    {
        [self.mapView zoomToGeometry:editGeom withPadding:25 animated:YES];
    }
}
@end