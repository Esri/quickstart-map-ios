//
//  EQSSampleViewController.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSSampleViewController.h"
#import "EQSPortalItemPickerView.h"

#import "EQSHelper.h"

#import	"AGSMapView+Navigation.h"
#import "AGSMapView+Basemaps.h"
#import "AGSMapView+EQSGraphics.h"
#import "AGSMapView+RouteDisplay.h"

#import "EQSSampleAppState.h"

#import "EQSGeoServices.h"
#import "EQSDefaultSymbols.h"

#import "EQSRouteResultsView.h"
#import "EQSCodeView.h"
#import "EQSAddressCandidateView.h"

#import "AGSMapView+GeneralUtilities.h"
#import "AGSPoint+GeneralUtilities.h"

#import "UIApplication+AppDimensions.h"

#import "EQSBasemapPickerView.h"
#import "EQSBasemapDetailsViewController.h"
#import <objc/runtime.h>

#define kEQSGetAddressReasonKey @"FindAddressReason"
#define kEQSGetAddressReason_RouteStart @"RouteStartPoint"
#define kEQSGetAddressReason_RouteEnd @"RouteEndPoint"
#define kEQSGetAddressReason_ReverseGeocodeForPoint @"FindAddressFunction"
#define kEQSGetAddressReason_AddressForGeolocation @"AddressForGeolocation"
#define kEQSGetAddressData_SearchPoint @"EQSGeoServices_ReverseGeocode_Data_SearchPoint"

@interface EQSSampleViewController ()
                                        <AGSPortalItemDelegate,
                                        AGSMapViewTouchDelegate,
//                                        AGSRouteTaskDelegate,
                                        UISearchBarDelegate,
//                                        AGSLocatorDelegate,
                                        UIWebViewDelegate,
                                        EQSBasemapPickerDelegate,
                                        AGSMapViewCalloutDelegate,
                                        EQSAddressCandidateViewDelegate,
                                        UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableOrderedSet *geocodeResults;
@property (nonatomic, strong) NSMutableOrderedSet *geolocationResults;

// General UI
@property (weak, nonatomic) IBOutlet UINavigationBar *functionNavBar_iPhone;
@property (weak, nonatomic) IBOutlet UIToolbar *functionToolBar;
@property (weak, nonatomic) IBOutlet UIView *routingPanel;
@property (weak, nonatomic) IBOutlet UIView *findPlacePanel;
@property (weak, nonatomic) IBOutlet UIView *cloudDataPanel;
@property (weak, nonatomic) IBOutlet UIView *geolocationPanel;
@property (weak, nonatomic) IBOutlet UIView *graphicsPanel;


@property (weak, nonatomic) IBOutlet UIButton *buttonShowUI;


@property (weak, nonatomic) IBOutlet UIView *messageBar;
@property (weak, nonatomic) IBOutlet UILabel *messageBarLabel;
- (IBAction)messageBarCloseTapped:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *cancelKeyboardButton;
- (IBAction)cancelKeyboardPressed:(id)sender;




@property (weak, nonatomic) IBOutlet UISearchBar *findAddressSearchBar;


// Basemaps
@property (weak, nonatomic) IBOutlet EQSBasemapPickerView *basemapsPicker;

@property (strong, nonatomic) NSMutableArray *basemapVCs;

@property (nonatomic, retain) AGSPortalItem *currentPortalItem;

//Graphics UI
@property (weak, nonatomic) IBOutlet UIButton *graphicButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPointsButton;
@property (weak, nonatomic) IBOutlet UIButton *clearLinesButton;
@property (weak, nonatomic) IBOutlet UIButton *clearPolysButton;
// Edit Graphics UI
@property (weak, nonatomic) IBOutlet UIToolbar *editGraphicsToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoEditGraphicsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoEditGraphicsButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteGraphicButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomToGraphicButton;

@property (weak, nonatomic) IBOutlet UIButton *graphicPointButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicLineButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicPolygonButton;

- (IBAction)doneEditingGraphic:(id)sender;
- (IBAction)cancelEditingGraphic:(id)sender;
- (IBAction)undoEditingGraphic:(id)sender;
- (IBAction)redoEditingGraphic:(id)sender;
- (IBAction)zoomToEditingGeometry:(id)sender;
- (IBAction)deleteSelectedGraphic:(id)sender;

- (IBAction)newPtGraphic:(id)sender;
- (IBAction)newLnGraphic:(id)sender;
- (IBAction)newPgGraphic:(id)sender;
- (IBAction)newMultiPtGraphic:(id)sender;

- (IBAction)swapRouteStartAndEnd:(id)sender;


// Directions UI
@property (weak, nonatomic) IBOutlet UIButton *routeStartButton;
@property (weak, nonatomic) IBOutlet UIButton *routeEndButton;
@property (weak, nonatomic) IBOutlet UILabel *routeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeEndLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearRouteButton;
// Directions Properties
@property (nonatomic, strong) AGSPoint *routeStartPoint;
@property (nonatomic, strong) AGSPoint *routeEndPoint;
@property (nonatomic, retain) NSString *routeStartAddress;
@property (nonatomic, retain) NSString *routeEndAddress;
//@property (nonatomic, retain) AGSRouteResult *routeResult;

@property (strong, nonatomic) IBOutlet EQSRouteResultsView *routeResultsView;

// Geolocation UI
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UILabel *myLocationAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *findScaleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *findMeScrollView;

// Non UI Properties
@property (assign) EQSBasemapType currentBasemapType;
@property (assign) BOOL uiControlsVisible;

@property (assign) EQSSampleAppState currentState;

@property (nonatomic, assign) NSUInteger findScale;

@property (nonatomic, assign) CGSize keyboardSize;

// Find Places
@property (weak, nonatomic) IBOutlet UIToolbar *findPlacesToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *findbutton;
@property (weak, nonatomic) IBOutlet UIScrollView *findPlacesScrollView;
@property (weak, nonatomic) IBOutlet UILabel *findPlacesNoResultsLabel;

@property (weak, nonatomic) IBOutlet EQSCodeView *codeViewer;
- (IBAction)findPlacesTapped:(id)sender;


// Actions
- (IBAction)addGraphics:(id)sender;

- (IBAction)clearPoints:(id)sender;
- (IBAction)clearLines:(id)sender;
- (IBAction)clearPolygons:(id)sender;

- (IBAction)findMe:(id)sender;
- (IBAction)findScaleChanged:(id)sender;
- (IBAction)zoomToLevel:(id)sender;

- (IBAction)functionChanged:(id)sender;

- (IBAction)toFromTapped:(id)sender;
- (IBAction)resizeUIGoFullScreen:(id)sender;
- (IBAction)resizeUIExitFullScreen:(id)sender;
@end

@implementation EQSSampleViewController
@synthesize editGraphicsToolbar = _editGraphicsToolbar;
@synthesize undoEditGraphicsButton = _undoEditGraphicsButton;
@synthesize redoEditGraphicsButton = _redoEditGraphicsButton;
@synthesize graphicPointButton = _graphicPointButton;
@synthesize graphicLineButton = _graphicLineButton;
@synthesize graphicPolygonButton = _graphicPolygonButton;
@synthesize geolocationPanel = _geolocationPanel;
@synthesize graphicsPanel = _graphicsPanel;
@synthesize buttonShowUI = _buttonShowUI;
@synthesize messageBar = _messageBar;
@synthesize messageBarLabel = _messageBarLabel;
@synthesize basemapsPicker = _basemapsPicker;
@synthesize graphicButton = _graphicButton;
@synthesize clearPointsButton = _clearPointsButton;
@synthesize clearLinesButton = _clearLinesButton;
@synthesize deleteGraphicButton = _deleteGraphicButton;
@synthesize zoomToGraphicButton = _zoomToGraphicButton;
@synthesize clearPolysButton = _clearPolysButton;
@synthesize routingPanel = _routingPanel;
@synthesize findPlacePanel = _findPlacePanel;
@synthesize cancelKeyboardButton = _cancelKeyboardButton;
@synthesize findAddressSearchBar = _findAddressSearchBar;
@synthesize cloudDataPanel = _cloudDataPanel;
@synthesize routeStartLabel = _routeStartLabel;
@synthesize routeEndLabel = _routeStopLabel;
@synthesize clearRouteButton = _clearRouteButton;

@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

@synthesize uiControlsVisible = _uiControlsVisible;

@synthesize currentState = _currentState;

@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeEndPoint = _routeEndPoint;
@synthesize routeStartAddress = _routeStartAddress;
@synthesize routeEndAddress = _routeEndAddress;

@synthesize findMeButton = _findMeButton;
@synthesize findScaleLabel = _findScaleLabel;
@synthesize findMeScrollView = _findMeScrollView;
@synthesize myLocationAddressLabel = _myLocationAddressLabel;
@synthesize functionNavBar_iPhone = _functionNavBar_iPhone;
@synthesize functionToolBar = _functionToolBar;
@synthesize routeStartButton = _routeStartButton;
@synthesize routeEndButton = _routeStopButton;

//@synthesize routeResult = _routeResult;
@synthesize routeResultsView = _routeResultsView;

@synthesize findScale = _findScale;

@synthesize basemapVCs = _basemapVCs;

@synthesize keyboardSize = _keyboardSize;
@synthesize findPlacesToolbar = _findToolbar;
@synthesize findbutton = _findbutton;
@synthesize findPlacesScrollView = _findPlacesScrollView;
@synthesize findPlacesNoResultsLabel = _findPlacesNoResultsLabel;
@synthesize codeViewer = _codeViewer;

@synthesize geocodeResults = _geocodeResults;
@synthesize geolocationResults = _geolocationResults;

//#define kEQSApplicationLocFromState @"ButtonState"

#pragma mark - Initialization Methods

- (void)initUI
{
    // Go through all the various UI component views, hide them and then place them properly
    // in the UI window so that they'll fade in and out properly.
    for (UIView *v in [self allUIViews]) {
        v.alpha = 0;
        v.hidden = YES;
        v.frame = [self getUIFrame:v];
    }
    
    self.geocodeResults = [NSMutableOrderedSet orderedSet];
    self.geolocationResults = [NSMutableOrderedSet orderedSet];
    
	// Track the application state
    self.currentState = EQSSampleAppStateBasemaps;

	[self initBasemapPicker];
    
    // Initialize the default symbols container. This will load them in the background (some are URL based,
    // which causes a synchronous HTTP request to block the initializer UIImage initializer).
    id tmp = self.mapView.defaultSymbols;
    tmp = nil;

    // Store some state on the UI so that we can track when the user is placing points for routing.
//    objc_setAssociatedObject(self.routeStartButton, kEQSApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    objc_setAssociatedObject(self.routeEndButton, kEQSApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // When we geolocate, what scale level to zoom the map to?
    self.findScale = 13;

    self.routeResultsView.hidden = YES;
    self.routeResultsView.alpha = 0;

    // And show the UI by default. Note, at present the UI is always visible.
    self.uiControlsVisible = YES;

    // We want to update the UI when the basemap is changed, so register our interest in a couple
    // of events.
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(basemapDidChange:)
												 name:kEQSNotification_BasemapDidChange
											   object:self.mapView];
	
	// We need to re-arrange the UI when the keyboard displays and hides, so let's find out when that happens.
	self.keyboardSize = CGSizeZero;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeDisplayCleared:)
                                                 name:kEQSRouteDisplayNotification_RouteCleared
                                               object:self.mapView.routeDisplayHelper];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeEditRequested:)
                                                 name:kEQSRouteDisplayNotification_EditRequested
                                               object:self.mapView.routeDisplayHelper];

    // Set up the map UI a little.
    self.mapView.wrapAround = YES;
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    
    self.findMeButton.layer.cornerRadius = 5;

    self.buttonShowUI.layer.borderColor = [UIColor blackColor].CGColor;
    self.buttonShowUI.layer.borderWidth = 2;
    self.buttonShowUI.layer.cornerRadius = 5;
    
    self.mapView.callout.leaderPositionFlags = AGSCalloutLeaderPositionBottom |
                                                AGSCalloutLeaderPositionLeft |
                                                AGSCalloutLeaderPositionRight;
}

#pragma mark - UIView Events

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize our property for tracking the current basemap type.
    self.currentBasemapType = EQSBasemapTypeTopographic;

	[self initUI];

	// Set up our map with a basemap, and jump to a location and scale level.
    [self.mapView setBasemap: self.currentBasemapType];
    [self.mapView zoomToLevel:13 withLat:40.7302 lon:-73.9958 animated:YES];

	[self registerForGeoServicesNotifications];
}

//    AGSPoint *nyc = [AGSPoint pointFromLat:40.7302 Lon:-73.9958];
//    [self.mapView centerAtPoint:nyc withScaleLevel:0];
//    [self.mapView centerAtLat:40.7302 Long:-73.9958];
//    [self.mapView zoomToLevel:7];
//    [self.mapView centerAtMyLocation];
//    [self.mapView centerAtMyLocationWithScaleLevel:15];

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setGraphicButton:nil];
    [self setClearPointsButton:nil];
    [self setClearLinesButton:nil];
    [self setClearPolysButton:nil];
    [self setRoutingPanel:nil];
    [self setRouteStartLabel:nil];
    [self setRouteEndLabel:nil];
    [self setFindScaleLabel:nil];
    [self setFunctionToolBar:nil];
    [self setFindPlacePanel:nil];
    [self setCloudDataPanel:nil];
    [self setGeolocationPanel:nil];
    [self setGraphicsPanel:nil];
    [self setEditGraphicsToolbar:nil];
    [self setUndoEditGraphicsButton:nil];
    [self setRedoEditGraphicsButton:nil];
    [self setRouteStartButton:nil];
    [self setRouteEndButton:nil];
    [self setClearRouteButton:nil];
	[self setFindAddressSearchBar:nil];
	[self setBasemapsPicker:nil];
    [self setFindbutton:nil];
    [self setFindPlacesToolbar:nil];
    [self setMessageBar:nil];
    [self setMessageBarLabel:nil];
    [self setRouteResultsView:nil];
    [self setCodeViewer:nil];
    [self setFindMeButton:nil];
    [self setMyLocationAddressLabel:nil];
    [self setGraphicPointButton:nil];
    [self setGraphicLineButton:nil];
    [self setGraphicPolygonButton:nil];
    [self setFindPlacesScrollView:nil];
    [self setFindPlacesNoResultsLabel:nil];
    [self setDeleteGraphicButton:nil];
    [self setFindMeScrollView:nil];
	[self setCancelKeyboardButton:nil];
    [self setZoomToGraphicButton:nil];
    [self setFunctionNavBar_iPhone:nil];
    [self setButtonShowUI:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - AGSMapView Events

- (BOOL) mapView:(AGSMapView *)mapView shouldShowCalloutForGraphic:(AGSGraphic *)graphic
{
    switch (self.currentState) {
        case EQSSampleAppStateGraphics:
        case EQSSampleAppStateGraphics_Editing:
            return NO;
            
        default:
            NSLog(@"SSC: %@", graphic);
            NSLog(@"SSC ITD: %@", graphic.infoTemplateDelegate);
            return (graphic.infoTemplateDelegate != nil);
    }
}

- (void) mapView:(AGSMapView *)mapView
 didClickAtPoint:(CGPoint)screen
        mapPoint:(AGSPoint *)mapPoint
        graphics:(NSDictionary *)graphics
{
    switch (self.currentState) {
        case EQSSampleAppStateGraphics:
            if (graphics.count > 0)
            {
                // The user selected a graphic. Let's edit it.
                if ([self.mapView editGraphicFromMapViewDidClickAtPoint:graphics])
                {
                    self.currentState = EQSSampleAppStateGraphics_Editing;
                }
            }
            break;

        case EQSSampleAppStateDirections_WaitingForRouteStart:
            [self didTapStartPoint:mapPoint];
            break;
            
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            [self didTapEndPoint:mapPoint];
            break;
            
        case EQSSampleAppStateFindPlace:
        {
            BOOL shouldReverseGeocode = YES;
            AGSGraphic *g = [self nearestGraphicToPoint:mapPoint FromMapViewClickedGraphics:graphics];
            if (g && g.infoTemplateDelegate)
            {
                [self.mapView showCalloutAtPoint:mapPoint forGraphic:g animated:YES];
                shouldReverseGeocode = NO;
            }
            if (shouldReverseGeocode)
            {
                [self didTapToReverseGeocode:mapPoint];
            }
        }
            break;
            
        default:
            for (id key in graphics.allKeys) {
                NSArray *graphicsInLayer = [graphics objectForKey:key];
                for (AGSGraphic *g in graphicsInLayer) {
                    NSLog(@"MVCAP: %@", g);
                    NSLog(@"MVCAP ITD: %@", g.infoTemplateDelegate);
                }
            }
            break;
    }
}

- (AGSGraphic *) nearestGraphicToPoint:(AGSPoint *)mapPoint FromMapViewClickedGraphics:(NSDictionary *)graphics
{
    if (graphics.count > 0)
    {
        // The AGS SDK has already worked out which graphics are candidates.
        double minDistance = -1;
        AGSGraphic *nearestGraphic = nil;
        NSArray *graphicsForLayer = nil;
        for (NSArray *layerGraphics in [graphics allValues])
        {
            if (layerGraphics.count > 0)
            {
                // The first layer with anything returned for it is what we'll focus on.
                graphicsForLayer = layerGraphics;
                break;
            }
        }
        
        // Now sort the array of graphics based on geometry type. We want to consider points over lines over polygons.
        NSArray *sortedGraphics = [graphicsForLayer sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AGSGraphic *g1 = obj1;
            AGSGraphic *g2 = obj2;
            AGSGeometryType t1 = AGSGeometryTypeForGeometry(g1.geometry);
            AGSGeometryType t2 = AGSGeometryTypeForGeometry(g2.geometry);
            
            if (t1 == AGSGeometryTypeMultipoint) t1 = AGSGeometryTypePoint;
            if (t2 == AGSGeometryTypeMultipoint) t2 = AGSGeometryTypePoint;
            
            NSNumber *n1 = [NSNumber numberWithInt:t1];
            NSNumber *n2 = [NSNumber numberWithInt:t2];
            
            NSLog(@"%d %d - %@ %@", t1, t2, n1, n2);
            
            return [n1 compare:n2];
        }];
        
        double immediateScreenThreshold = 10;
        CGPoint screenPt = [self.mapView toScreenPoint:mapPoint];

        // Now find the closest geometry to where we tapped.
        for (AGSGraphic *graphic in sortedGraphics)
        {
            AGSProximityResult *r = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:graphic.geometry toPoint:mapPoint];
            CGPoint screenR = [self.mapView toScreenPoint:r.point];
            double dx = (screenR.x - screenPt.x);
            double dy = (screenR.y - screenPt.y);
            double screenDist = sqrt(dx*dx + dy*dy);
            if (screenDist < immediateScreenThreshold)
            {
                return graphic;
            }
            
            double dist = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:mapPoint toGeometry:graphic.geometry];
            if (minDistance == -1 || dist < minDistance)
            {
                minDistance = dist;
                nearestGraphic = graphic;
            }
        }
        return nearestGraphic;
    }
    return nil;
}

#pragma mark - Keyboard Events

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    NSLog(@"Keyboard will show: %@", NSStringFromCGSize(self.keyboardSize));
    [self updateUIDisplayState:notification];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
	self.cancelKeyboardButton.hidden = NO;
}

- (IBAction)cancelKeyboardPressed:(id)sender
{
	[self.view endEditing:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardSize = CGSizeZero;
	self.cancelKeyboardButton.hidden = YES;
    [self updateUIDisplayState:notification];
}

#pragma mark - UI Position and size

- (CGPoint) getUIComponentOrigin
{
    CGRect topFrame = self.functionToolBar.frame;
    CGPoint newOrigin = CGPointMake(topFrame.origin.x, topFrame.origin.y + topFrame.size.height);
    return newOrigin;
}

- (CGRect) getUIFrame:(UIView *)viewToDisplay
{
    return [self getUIFrame:viewToDisplay
                       forOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGRect) getUIFrame:(UIView *)viewToDisplay forOrientation:(UIInterfaceOrientation)orientation
{
    CGRect screenFrame = [UIApplication frameInOrientation:orientation];
    CGRect viewFrame = viewToDisplay.frame;
    double keyboardHeight = self.keyboardSize.height;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //TODO - make a constant
        CGFloat frameHeight = -1;
        if (self.currentState == EQSSampleAppStateFindPlace)
        {
            if (keyboardHeight == 0)
            {
                frameHeight = 144;
            }
            else
            {
                // We want to hide the scrollview.
                frameHeight = 44;
            }
        }
        else if (self.currentState == EQSSampleAppStateGraphics_Editing)
        {
            frameHeight = 44;
        }
        else if (self.currentState == EQSSampleAppStateGraphics)
        {
            frameHeight = 114;
        }
        else if (self.currentState == EQSSampleAppStateDirections_Navigating)
        {
            frameHeight = 130;
        }
        if (frameHeight != -1)
        {
            viewFrame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, frameHeight);
        }
    }

    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        // Why? WHY!!!? But OK. If I have to.
        keyboardHeight = self.keyboardSize.width;
    }
	//    NSLog(@"Screen Height: %f, view Height: %f, keyboard Height: %f", screenFrame.size.height, viewFrame.size.height, keyboardHeight);
    CGPoint origin = CGPointMake(screenFrame.origin.x, screenFrame.size.height - viewFrame.size.height - keyboardHeight);
	//    NSLog(@"Screen: %@", NSStringFromCGRect(screenFrame));
    CGRect newFrame = CGRectMake(origin.x, origin.y, viewFrame.size.width, viewFrame.size.height);
	//    NSLog(@"   New: %@", NSStringFromCGRect(newFrame));
    return newFrame;
}

- (CGRect) getUIFrameWhenHidden:(UIView *)viewToHide
{
    return [self getUIFrameWhenHidden:viewToHide
                       forOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGRect) getUIFrameWhenHidden:(UIView *)viewToHide forOrientation:(UIInterfaceOrientation)orientation
{
    CGRect screenFrame = [UIApplication frameInOrientation:orientation];
    CGPoint origin = CGPointMake(screenFrame.origin.x, screenFrame.size.height);
    CGSize viewSize = viewToHide.frame.size;
    // Position it to the left of the screen.
    CGRect newFrame = CGRectMake(origin.x, origin.y, viewSize.width, viewSize.height);
    return newFrame;
}

- (CGRect) getMessageFrameForMasterFrame:(UIView *)masterView
{
    double messageHeight = CGRectGetHeight(self.messageBar.frame);
    CGRect masterFrame = masterView.frame;
    CGRect messageFrame = CGRectMake(masterFrame.origin.x, masterFrame.origin.y - messageHeight, masterFrame.size.width, messageHeight);
    
//    NSLog(@"Master: %@\nMessage: %@", NSStringFromCGRect(masterFrame), NSStringFromCGRect(messageFrame));

    return messageFrame;
}

#pragma mark - Application State

- (EQSSampleAppState)currentState
{
    return _currentState;
}

- (void) setCurrentState:(EQSSampleAppState)currentState
{
    _currentState = currentState;
    
    switch (_currentState) {
        case EQSSampleAppStateDirections:
			self.routeStartButton.selected = NO;
			self.routeEndButton.selected = NO;
            [self setStartText];
            [self setEndText];
            break;
        case EQSSampleAppStateDirections_WaitingForRouteStart:
//            self.routeStartLabel.text = @"Tap a point on the map…";
			self.routeStartButton.selected = YES;
			self.routeEndButton.selected = NO;
            [self setStartText];
            [self setEndText];
            break;
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
//            self.routeEndLabel.text = @"Tap a point on the map…";
			self.routeEndButton.selected = YES;
			self.routeStartButton.selected = NO;
            [self setStartText];
            [self setEndText];
            break;
            
        case EQSSampleAppStateGraphics_Editing:
            for (UIBarButtonItem *buttonItem in self.editGraphicsToolbar.items) {
                buttonItem.enabled = YES;
            }
            if (![self.mapView getCurrentEditGraphic])
            {
                self.deleteGraphicButton.enabled = NO;
            }
            [self setZoomToGraphicButtonState];
            [self setUndoRedoButtonStates];
            [self listenToEditingUndoManager];
            self.mapView.showMagnifierOnTapAndHold = YES;
            break;
        case EQSSampleAppStateGraphics:
            for (UIBarButtonItem *buttonItem in self.editGraphicsToolbar.items) {
                buttonItem.enabled = NO;
            }
            self.mapView.showMagnifierOnTapAndHold = NO;
            break;
            
        default:
            break;
    }
    
    [self.view endEditing:YES];

    [self updateUIDisplayState];
    
    self.codeViewer.viewController.currentAppState = _currentState;
}

#pragma mark - UI Function Selection

- (NSString *) getMessageForCurrentFunction
{
    switch (self.currentState) {
        case EQSSampleAppStateBasemaps:
            return @"Select a basemap";
            break;
        case EQSSampleAppStateGeolocation:
            return @"Zoom to your location";
            break;
        case EQSSampleAppStateGraphics:
        case EQSSampleAppStateGraphics_Editing:
            return @"Tap the map to add graphics";
            break;
        case EQSSampleAppStateFindPlace:
            return @"Tap the map or enter an address";
            break;
        case EQSSampleAppStateDirections:
            return @"Tap the map calculate directions";
            break;
        case EQSSampleAppStateDirections_WaitingForRouteStart:
            return @"Tap the start point for calculating directions";
            break;
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            return @"Tap the end point for calculating directions";
        case EQSSampleAppStateCloudData:
            return @"Access World City features in the cloud";
            break;
            
        default:
            NSLog(@"Can't get message for unknown app state %d", self.currentState);
            return @"Magic unknown functionality! Well done!";
            break;
    }
}

- (IBAction)functionChanged:(id)sender {
    UISegmentedControl *seg = sender;
    switch (seg.selectedSegmentIndex) {
        case 0:
            self.currentState = EQSSampleAppStateBasemaps;
            break;
        case 1:
            self.currentState = EQSSampleAppStateGeolocation;
            break;
        case 2:
            self.currentState = EQSSampleAppStateGraphics;
            break;
        case 3:
            self.currentState = EQSSampleAppStateCloudData;
            break;
        case 4:
            self.currentState = EQSSampleAppStateFindPlace;
            break;
        case 5:
            if (self.mapView.routeDisplayHelper.currentRouteResult)
            {
                self.currentState = EQSSampleAppStateDirections_Navigating;
            }
            else
            {
                self.currentState = EQSSampleAppStateDirections;
            }
            break;
        default:
            NSLog(@"Set state to %d", seg.selectedSegmentIndex);
            break;
    }
}

- (NSMutableArray *)allUIViews
{
    NSMutableArray *uiViews = [NSMutableArray arrayWithObjects:self.routingPanel,
                               self.basemapsPicker,
                               self.geolocationPanel,
                               self.findPlacePanel,
                               self.graphicsPanel,
                               self.cloudDataPanel, nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        [uiViews addObject:self.routeResultsView];
    }
    return uiViews;
}

- (UIView *) getViewToShow
{
    UIView *viewToShow = nil;
    
    switch (self.currentState) {
        case EQSSampleAppStateBasemaps:
            viewToShow = self.basemapsPicker;
            break;
        case EQSSampleAppStateDirections:
        case EQSSampleAppStateDirections_WaitingForRouteStart:
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            viewToShow = self.routingPanel;
            break;
        case EQSSampleAppStateDirections_Navigating:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone &&
                self.mapView.routeDisplayHelper.currentRouteResult != nil)
            {
                viewToShow = self.routeResultsView;
            }
            else
            {
                viewToShow = self.routingPanel;
            }
            break;
        case EQSSampleAppStateFindPlace:
            viewToShow = self.findPlacePanel;
            break;
        case EQSSampleAppStateCloudData:
            viewToShow = self.cloudDataPanel;
            break;
        case EQSSampleAppStateGeolocation:
            viewToShow = self.geolocationPanel;
            break;
        case EQSSampleAppStateGraphics:
        case EQSSampleAppStateGraphics_Editing:
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

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateUIDisplayStateOverDuration:0];
    [self.codeViewer.viewController refreshCodeSnippetViewerPosition];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateUIDisplayStateOverDuration:duration forOrientation:toInterfaceOrientation];
}

- (void)updateUIDisplayState
{
    [self updateUIDisplayStateOverDuration:0.4];
}

- (void)updateUIDisplayState:(NSNotification *)keyboardNotification
{
    if (keyboardNotification)
    {
        NSTimeInterval animationDuration;
        NSValue *value = [keyboardNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [value getValue:&animationDuration];
        [self updateUIDisplayStateOverDuration:animationDuration];
    }
    else
    {
        [self updateUIDisplayState];
    }
}

- (void)updateUIDisplayStateOverDuration:(NSTimeInterval)animationDuration
{
    [self updateUIDisplayStateOverDuration:animationDuration
                            forOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)updateUIDisplayStateOverDuration:(NSTimeInterval)animationDuration forOrientation:(UIInterfaceOrientation)orientation
{
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
                             viewToShow.frame = [self getUIFrame:viewToShow forOrientation:orientation];
                             self.messageBar.frame = [self getMessageFrameForMasterFrame:viewToShow];
                             self.messageBarLabel.text = [self getMessageForCurrentFunction];
                         }
                         completion:^(BOOL finished) {
                             viewToAnimateOut.hidden = YES;
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            if (self.currentState == EQSSampleAppStateDirections ||
                self.currentState == EQSSampleAppStateDirections_WaitingForRouteStart ||
                self.currentState == EQSSampleAppStateDirections_WaitingForRouteEnd)
            {
                self.routeResultsView.viewController.hidden = NO;
            }
            else
            {
                self.routeResultsView.viewController.hidden = YES;
            }
        }
        else
        {
            if (self.currentState == EQSSampleAppStateDirections_Navigating)
            {
                self.routeResultsView.viewController.hidden = NO;
            }
            else
            {
                self.routeResultsView.viewController.hidden = YES;
            }
        }
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





#pragma mark - Undo/Redo

- (void) setUndoRedoButtonStatesForUndoManager:(NSUndoManager *)um
{
    if (um)
    {
        self.undoEditGraphicsButton.enabled = um.canUndo;
        self.redoEditGraphicsButton.enabled = um.canRedo;
    }
}

- (void) setZoomToGraphicButtonState
{
    AGSGeometry *editGeom = [self.mapView getCurrentEditGeometry];
    self.zoomToGraphicButton.enabled = !editGeom.isEmpty;
}

- (void) setUndoRedoButtonStates
{
    [self setUndoRedoButtonStatesForUndoManager:[self.mapView getUndoManagerForGraphicsEdits]];
}

- (void) editUndoRedoChanged:(NSNotification *)notification
{
    NSUndoManager *um = notification.object;
    [self setUndoRedoButtonStatesForUndoManager:um];
    [self setZoomToGraphicButtonState];
}

- (void)listenToEditingUndoManager
{
    [self.mapView registerListener:self ForEditGraphicUndoRedoNotificationsUsing:@selector(editUndoRedoChanged:)];
}


#pragma mark - Basemap Selection

// Populate the PortalItemViewer with items based off our Basemap List
- (void) initBasemapPicker
{
	self.basemapsPicker.basemapDelegate = self;
	self.basemapsPicker.basemapType = self.currentBasemapType;
}

- (void)basemapSelected:(EQSBasemapType)basemapType
{
	self.currentBasemapType = basemapType;
	self.currentPortalItem = self.basemapsPicker.currentPortalItem;
	[self.mapView setBasemap:basemapType];
}

- (EQSBasemapType)currentBasemapType
{
    return _currentBasemapType;
}

- (void)setCurrentBasemapType:(EQSBasemapType)currentBasemapType
{
    _currentBasemapType = currentBasemapType;
	
	NSString *portalItemID = [EQSHelper getBasemapWebMap:_currentBasemapType].portalItem.itemId;
	
	self.basemapsPicker.currentPortalItemID = portalItemID;
}

- (void)basemapDidChange:(NSNotification *)notification
{
    AGSPortalItem *pi = [notification basemapPortalItem];
    EQSBasemapType basemapType = [notification basemapType];
    self.currentBasemapType = basemapType;
    if (pi)
    {
        self.currentPortalItem = pi;
    }
	
	self.basemapsPicker.currentPortalItemID = pi.itemId;
}





#pragma mark - Basemap Info

- (void)basemapsPickerDidTapInfoButton:(id)basemapsPicker
{
	if (basemapsPicker == self.basemapsPicker)
	{
		// It's us.
		[self performSegueWithIdentifier:@"showBasemapInfo" sender:self];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // If the Info Modal View is about to be shown, tell it what PortalItem we're showing.
    if ([segue.identifier isEqualToString:@"showBasemapInfo"])
    {
        EQSBasemapDetailsViewController *destVC = segue.destinationViewController;
        destVC.portalItem = self.currentPortalItem;
    }
}





#pragma mark - Graphics

- (IBAction)addGraphics:(id)sender {
    [self.mapView addPointAtLat:40.7302 lon:-73.9958];
    [self.mapView addLineFromPoints:[NSArray arrayWithObjects:[AGSPoint pointFromLat:40.7302 lon:-73.9958],
									 [AGSPoint pointFromLat:41.0 lon:-73.9], nil]];
    [self.mapView addPolygonFromPoints:[NSArray arrayWithObjects:[AGSPoint pointFromLat:40.7302 lon:-73.9958],
										[AGSPoint pointFromLat:40.85 lon:-73.65],
										[AGSPoint pointFromLat:41.0 lon:-73.7],nil]];
}

- (IBAction)newPtGraphic:(id)sender {
    [self.mapView createAndEditNewPoint];
    self.currentState = EQSSampleAppStateGraphics_Editing;
}

- (IBAction)newLnGraphic:(id)sender {
    [self.mapView createAndEditNewLine];
    self.currentState = EQSSampleAppStateGraphics_Editing;
}

- (IBAction)newPgGraphic:(id)sender {
    [self.mapView createAndEditNewPolygon];
    self.currentState = EQSSampleAppStateGraphics_Editing;
}

- (IBAction)newMultiPtGraphic:(id)sender {
    [self.mapView createAndEditNewMultipoint];
    self.currentState = EQSSampleAppStateGraphics_Editing;
}

- (IBAction)clearPoints:(id)sender {
    [self.mapView clearGraphics:EQSGraphicsLayerTypePoint];
}

- (IBAction)clearLines:(id)sender {
    [self.mapView clearGraphics:EQSGraphicsLayerTypePolyline];
}

- (IBAction)clearPolygons:(id)sender {
    [self.mapView clearGraphics:EQSGraphicsLayerTypePolygon];
}

- (IBAction)doneEditingGraphic:(id)sender {
    [self.mapView saveGraphicEdit];
    self.currentState = EQSSampleAppStateGraphics;
}

- (IBAction)cancelEditingGraphic:(id)sender {
    [self.mapView cancelGraphicEdit];
    self.currentState = EQSSampleAppStateGraphics;
}

- (IBAction)undoEditingGraphic:(id)sender {
    [self.mapView undoGraphicEdit];
}

- (IBAction)redoEditingGraphic:(id)sender {
    [self.mapView redoGraphicEdit];
}

- (IBAction)zoomToEditingGeometry:(id)sender {
    AGSGeometry *editGeom = [self.mapView getCurrentEditGeometry];
    if (editGeom)
    {
        [self.mapView zoomToGeometry:editGeom withPadding:100 animated:YES];
    }
}

- (IBAction)deleteSelectedGraphic:(id)sender
{
    AGSGraphic *graphicToDelete = [self.mapView cancelGraphicEdit];
    [self.mapView removeGraphic:graphicToDelete];
    self.currentState = EQSSampleAppStateGraphics;
}





#pragma mark - Geocoding
- (void) didGetAddressFromPoint:(NSNotification *)notification
{
	NSOperation *op = [notification geoServicesOperation];
	
	if (op)
	{
		AGSAddressCandidate *candidate = [notification findAddressCandidate];
		
		NSDictionary *ad = candidate.address;
		NSString *street = [ad objectForKey:kEQSAddressCandidateAddressField];
		if (street != (id)[NSNull null])
		{
			street = [NSString stringWithFormat:@"%@, ", street];
		}
		else {
			street = @"";
		}
		NSString *address = [NSString stringWithFormat:@"%@%@, %@ %@",
							 street,
							 [ad objectForKey:kEQSAddressCandidateCityField],
							 [ad objectForKey:kEQSAddressCandidateStateField],
							 [ad objectForKey:kEQSAddressCandidateZipField]];
		
		// We're only interested in Reverse Geocodes that happened as a result of
		// start or end points of the route being clicked...
		NSString *source = objc_getAssociatedObject(op, kEQSGetAddressReasonKey);
		if (source)
		{
			// OK, this is something we requested and so we should be able to work
			// out what to do with it.
			
			if ([source isEqualToString:kEQSGetAddressReason_RouteStart])
			{
				self.routeStartAddress = address;
				self.routeStartPoint = candidate.location;
			}
			else if ([source isEqualToString:kEQSGetAddressReason_RouteEnd])
			{
				self.routeEndAddress = address;
				self.routeEndPoint = candidate.location;
			}
			else if ([source isEqualToString:kEQSGetAddressReason_ReverseGeocodeForPoint])
			{
                AGSPoint *p = candidate.location;//] getWebMercatorAuxSpherePoint];
                AGSGraphic *g = [self.mapView addPoint:p withSymbol:self.mapView.defaultSymbols.reverseGeocode];
                [g.attributes setObject:@"ReverseGeocoded" forKey:@"Source"];
                [g.attributes addEntriesFromDictionary:candidate.attributes];
                
                EQSAddressCandidatePanelViewController *cvc =
                [[EQSAddressCandidatePanelViewController alloc] initWithAddressCandidate:candidate
                                                                             OfType:EQSCandidateTypeReverseGeocode];
                cvc.candidateViewDelegate = self;
                cvc.graphic = g;
                [cvc addToScrollView:self.findPlacesScrollView];
                [self.geocodeResults addObject:cvc];

                [self.mapView showCalloutAtPoint:p forGraphic:g animated:YES];
			}
            else if ([source isEqualToString:kEQSGetAddressReason_AddressForGeolocation])
            {
                AGSPoint *geoLocation = [notification findAddressSearchPoint];
                AGSGraphic *g = [self.mapView addPoint:geoLocation withSymbol:self.mapView.defaultSymbols.geolocation];
                [g.attributes setObject:@"GeoLocation" forKey:@"Source"];
                [g.attributes addEntriesFromDictionary:candidate.attributes];

                EQSAddressCandidatePanelViewController *cvc =
                [[EQSAddressCandidatePanelViewController alloc] initWithAddressCandidate:candidate
                                                                             OfType:EQSCandidateTypeGeolocation];
                cvc.candidateViewDelegate = self;
                cvc.graphic = g;
                [cvc addToScrollView:self.findMeScrollView];
                [self.geolocationResults addObject:cvc];

                self.myLocationAddressLabel.text = address;

                [self.mapView showCalloutAtPoint:geoLocation forGraphic:g animated:YES];
            }
		}
	}
}

- (void) didFailToGetAddressFromPoint:(NSNotification *)notification
{
	NSError *error = [notification geoServicesError];
	NSLog(@"Failed to get address for location: %@", error);

    AGSPoint *failedPoint = [notification findAddressSearchPoint];
    AGSGraphic *g = [self.mapView addPoint:failedPoint withSymbol:self.mapView.defaultSymbols.failedGeocode];
    [g.attributes setObject:@"FailedGeocode" forKey:@"Source"];
    
    EQSDummyAddressCandidate *dummyCandidate =
        [[EQSDummyAddressCandidate alloc] initWithLocation:failedPoint
                                           andSearchRadius:[notification findAddressSearchDistance]];
    EQSAddressCandidatePanelViewController *acvc =
        [EQSAddressCandidatePanelViewController viewControllerWithCandidate:dummyCandidate
                                                                OfType:EQSCandidateTypeFailedGeocode];
    acvc.candidateViewDelegate = self;
    acvc.graphic =g;
    [acvc addToScrollView:self.findPlacesScrollView];
    [self.geocodeResults addObject:acvc];
    [self.mapView showCalloutAtPoint:failedPoint forGraphic:g animated:YES];
}



#pragma mark - GeoServices Registration
- (void)registerForGeoServicesNotifications
{
	// Let me know when the Geoservices object finds an address for a point.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didGetAddressFromPoint:)
												 name:kEQSGeoServicesNotification_AddressFromPoint_OK
											   object:self.mapView.geoServices];
    // Or not...
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFailToGetAddressFromPoint:)
												 name:kEQSGeoServicesNotification_AddressFromPoint_Error
											   object:self.mapView.geoServices];
    
    // And I also want to know when it found directions we asked for.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSolveRouteOK:)
												 name:kEQSGeoServicesNotification_FindRoute_OK
											   object:self.mapView.geoServices];
    // Or not...
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFailToSolveRoute:)
												 name:kEQSGeoServicesNotification_FindRoute_Error
											   object:self.mapView.geoServices];
    
    // And let me know when it finds points for an address.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotCandidatesForAddress:)
                                                 name:kEQSGeoServicesNotification_PointsFromAddress_OK
                                               object:self.mapView.geoServices];
    // Or not...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToGetCandidatesForAddress:)
                                                 name:kEQSGeoServicesNotification_PointsFromAddress_Error
                                               object:self.mapView.geoServices];
    
    
    // If I ask where I am, let me know it's foudn me
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGeolocate:)
                                                 name:kEQSGeoServicesNotification_Geolocation_OK
                                               object:self.mapView.geoServices];
    // Or not...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToGeolocate:)
                                                 name:kEQSGeoServicesNotification_Geolocation_Error
                                               object:self.mapView.geoServices];
}

#pragma mark - Geolocation
- (void) didGeolocate:(NSNotification *)notification
{
    CLLocation *location = [notification geolocationResult];
    
    if (location)
    {
        self.myLocationAddressLabel.text = location.description;
        AGSPoint *locPt = [AGSPoint pointFromLat:location.coordinate.latitude lon:location.coordinate.longitude];
        NSOperation *op = [self.mapView.geoServices findAddressFromPoint:locPt];
        objc_setAssociatedObject(op,
                                 kEQSGetAddressReasonKey, kEQSGetAddressReason_AddressForGeolocation,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void) didFailToGeolocate:(NSNotification *)notification
{
    self.myLocationAddressLabel.text = @"";
    NSError *err = [notification geoServicesError];
    NSString *errorMessage = [NSString stringWithFormat:@"Unable to get geolocation\n\"%@\"", err];
    [[[UIAlertView alloc] initWithTitle:@"Geolocation Error" message:errorMessage
                               delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}




#pragma mark - Reverse Geocode
- (void)didTapToReverseGeocode:(AGSPoint *)mapPoint
{
	NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReason_ReverseGeocodeForPoint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




#pragma mark - Directions
- (void)didTapStartPoint:(AGSPoint *)mapPoint
{
    NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReason_RouteStart, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTapEndPoint:(AGSPoint *)mapPoint
{
    NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReason_RouteEnd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) setRouteStartPoint:(AGSPoint *)routeStartPoint
{
    _routeStartPoint = routeStartPoint;
    if (_routeStartPoint)
    {
		self.currentState = EQSSampleAppStateDirections;
        [self setToFromButton:self.routeStartButton selectedState:NO];
        if (![self doRouteIfPossible])
		{
			self.currentState = EQSSampleAppStateDirections_WaitingForRouteEnd;
		}
    }
    [self setStartText];
}

- (void) setRouteEndPoint:(AGSPoint *)routeEndPoint
{
    _routeEndPoint = routeEndPoint;
    if (_routeEndPoint)
    {
		self.currentState = EQSSampleAppStateDirections;
        [self setToFromButton:self.routeEndButton selectedState:NO];
        if (![self doRouteIfPossible])
		{
			self.currentState = EQSSampleAppStateDirections_WaitingForRouteStart;
		}
	}
    [self setEndText];
}

- (void) setRouteStartAddress:(NSString *)routeStartAddress
{
    _routeStartAddress = routeStartAddress;
    [self setStartText];
}

- (void) setRouteEndAddress:(NSString *)routeEndAddress
{
    _routeEndAddress = routeEndAddress;
    [self setEndText];
}

- (BOOL) doRouteIfPossible
{
    if (self.routeStartPoint &&
        self.routeEndPoint)
    {
        NSLog(@"Start and end points set... %@ %@", self.routeStartAddress, self.routeEndAddress);
        [self.mapView.geoServices findDirectionsFrom:self.routeStartPoint named:self.routeStartAddress
                                                  to:self.routeEndPoint named:self.routeEndAddress];
        return YES;
    }
    return NO;
}

- (IBAction)swapRouteStartAndEnd:(id)sender {
    NSString *temp = self.routeStartAddress;
    self.routeStartAddress = self.routeEndAddress;
    self.routeEndAddress = temp;
    
    AGSPoint *tempPt = _routeStartPoint;
    _routeStartPoint = _routeEndPoint;
    _routeEndPoint = tempPt;
    
    switch (self.currentState) {
        case EQSSampleAppStateDirections_WaitingForRouteStart:
            self.currentState = EQSSampleAppStateDirections_WaitingForRouteEnd;
            break;
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            self.currentState = EQSSampleAppStateDirections_WaitingForRouteStart;
            break;
        case EQSSampleAppStateDirections:
            [self doRouteIfPossible];
            break;

        default:
            // Do nothing.
            break;
    }
}

- (void) didSolveRouteOK:(NSNotification *)notification
{
    NSLog(@"Entered didSolveRouteOK");

	AGSRouteTaskResult *results = [notification routeTaskResults];
    NSLog(@"Got UserInfo");
	if (results)
	{
        // Store the route result for ourselves.
//		self.routeResult = [results.routeResults objectAtIndex:0];
        
        // Tell our RouteDisplayHelper about the object we've created in our NIB for the table view.
        self.mapView.routeDisplayHelper.routeResultsViewController = self.routeResultsView.viewController;
		[self.mapView.routeDisplayHelper showRouteResult:results];
        
        self.currentState = EQSSampleAppStateDirections_Navigating;
	}
}

- (void) didFailToSolveRoute:(NSNotification *)notification
{
	NSError *error = [notification geoServicesError];
	if (error)
	{
		NSLog(@"Failed to solve route: %@", error);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not calculate route"
														message:[error.userInfo objectForKey:@"NSLocalizedFailureReason"]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
	}
}

- (void) setStartText
{
    NSString *latLongText = nil;
    if (self.routeStartPoint)
    {
        latLongText = [NSString stringWithFormat:@"%.4f,%.4f", self.routeStartPoint.latitude, self.routeStartPoint.longitude];
    }
    NSString *address = self.routeStartAddress;
    if (latLongText && address)
    {
        self.routeStartLabel.text = [NSString stringWithFormat:@"%@ (%@)", address, latLongText];
    }
    else if (latLongText)
    {
        self.routeStartLabel.text = latLongText;
    }
    else if (address)
    {
        self.routeStartLabel.text = address;
    }
    else
    {
        if (self.routeStartButton.selected)
        {
            self.routeStartLabel.text = @"Tap start of route on map";
        }
        else
        {
            self.routeStartLabel.text = @"Tap button";
        }
    }
}

- (void) setEndText
{
    NSString *latLongText = nil;
    if (self.routeEndPoint)
    {
        latLongText = [NSString stringWithFormat:@"%.4f,%.4f", self.routeEndPoint.latitude, self.routeEndPoint.longitude];
    }
    NSString *address = self.routeEndAddress;
    if (latLongText && address)
    {
        self.routeEndLabel.text = [NSString stringWithFormat:@"%@ (%@)", address, latLongText];
    }
    else if (latLongText)
    {
        self.routeEndLabel.text = latLongText;
    }
    else if (address)
    {
        self.routeEndLabel.text = address;
    }
    else
    {
        if (self.routeEndButton.selected)
        {
            self.routeEndLabel.text = @"Tap end of route on map";
        }
        else
        {
            self.routeEndLabel.text = @"Tap button";
        }
    }
}

- (void) routeDisplayCleared:(NSNotification *)notification
{
    self.routeStartAddress = nil;
    self.routeEndAddress = nil;
    self.routeStartPoint = nil;
    self.routeEndPoint = nil;
    self.currentState = EQSSampleAppStateDirections_WaitingForRouteStart;
}

- (void) routeEditRequested:(NSNotification *)notification
{
    self.currentState = EQSSampleAppStateDirections;
}

- (void)setToFromButton:(UIButton *)bi selectedState:(BOOL)selected
{
    // Clear the other button regardless of the new state for this one.
    UIButton *otherBi = (bi == self.routeStartButton)?self.routeEndButton:self.routeStartButton;
	//    otherBi.tintColor = nil;
    otherBi.selected = NO;
	//    UIColor *tintColor = (bi == self.routeStartButton)?[UIColor greenColor]:[UIColor redColor];
    otherBi.selected = NO;
//    objc_setAssociatedObject(otherBi, kEQSApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Set the new state for this one, and set our app state too.
    NSLog(@"Selected: %@", selected?@"YES":@"NO");
    bi.selected = selected;
    if (selected)
    {
		//        bi.tintColor = [UIColor colorWithWhite:0.6 alpha:1];
		//        bi.tintColor = tintColor;
        self.currentState = (bi == self.routeStartButton)?EQSSampleAppStateDirections_WaitingForRouteStart:EQSSampleAppStateDirections_WaitingForRouteEnd;
    }
    else
    {
		//        bi.tintColor = nil;
        self.currentState = EQSSampleAppStateDirections;
    }
    bi.selected = selected;
//    objc_setAssociatedObject(bi, kEQSApplicationLocFromState, [NSNumber numberWithBool:selected], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IBAction)toFromTapped:(id)sender {
//    BOOL selected = [(NSNumber *)objc_getAssociatedObject(sender, kEQSApplicationLocFromState) boolValue];
    BOOL selected = ((UIButton *)sender).selected;
    [self setToFromButton:sender selectedState:!selected];
}

- (IBAction)resizeUIGoFullScreen:(id)sender
{
    self.buttonShowUI.hidden = YES;
    self.buttonShowUI.alpha = 0;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.functionNavBar_iPhone.alpha = 0;
                         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                         self.view.frame = [UIScreen mainScreen].applicationFrame;
                         self.buttonShowUI.hidden = NO;
                     }
                     completion:^(BOOL finished) {
                         self.functionNavBar_iPhone.hidden = YES;
                         [UIView animateWithDuration:0.4 animations:^{
                             self.buttonShowUI.alpha = 1;
                         }];
                     }];
}

- (IBAction)resizeUIExitFullScreen:(id)sender
{
    self.functionNavBar_iPhone.alpha = 0;
    self.functionNavBar_iPhone.hidden = NO;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.buttonShowUI.alpha = 0;
                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                         self.view.frame = [UIScreen mainScreen].applicationFrame;
                         self.functionNavBar_iPhone.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.buttonShowUI.hidden = YES;
                     }];
}


#pragma mark - Find Address

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *searchString = searchBar.text;
    [self findPlaces:searchString];
    [searchBar resignFirstResponder];
}

- (IBAction)findPlacesTapped:(id)sender {
    NSString *searchString = self.findAddressSearchBar.text;
    [self findPlaces:searchString];
}

- (void)findPlaces:(NSString *)searchString
{
	[self.findAddressSearchBar resignFirstResponder];
	NSLog(@"Searching for: %@", searchString);
    AGSPolygon *v = self.mapView.visibleArea;
    AGSEnvelope *env = v.envelope;
	[self.mapView.geoServices findPlaces:searchString withinEnvelope:env];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

//- (id<AGSInfoTemplateDelegate>) geocodeInfoTemplateDelegate
//{
//    if (!_geocodeInfoTemplateDelegate)
//    {
//        AGSCalloutTemplate *template = [[AGSCalloutTemplate alloc] init];
//        template.detailTemplate = @"Stuff goes here\nAnd here";
//        template.titleTemplate = @"${Addr_Type}";
//        _geocodeInfoTemplateDelegate = template;
//    }
//    return _geocodeInfoTemplateDelegate;
//}
//
- (void) gotCandidatesForAddress:(NSNotification *)notification
{
    NSOperation *op = [notification geoServicesOperation];
	
    if (op)
    {
        NSArray *candidates = [notification findPlacesCandidates];
        if (candidates.count > 0)
        {
            // First, let's remove all the old items (if any)
            NSMutableArray *geocodeResultsToDiscard = [NSMutableArray array];
            for (EQSAddressCandidatePanelViewController *gcvc in self.geocodeResults)
            {
                if (gcvc.candidateType == EQSCandidateTypeForwardGeocode)
                {
                    [gcvc.graphic.layer removeGraphic:gcvc.graphic];
                    [gcvc removeFromParentScrollView];
                    [geocodeResultsToDiscard addObject:gcvc];
                }
            }
            [self.geocodeResults removeObjectsInArray:geocodeResultsToDiscard];

            self.mapView.callout.hidden = YES;
            
            self.findPlacesNoResultsLabel.hidden = YES;

            NSArray *sortedCandidates = [candidates sortedArrayUsingComparator:^(id obj1, id obj2) {
                AGSAddressCandidate *c1 = obj1;
                AGSAddressCandidate *c2 = obj2;
                return (c1.score==c2.score)?NSOrderedSame:(c1.score > c2.score)?NSOrderedAscending:NSOrderedDescending;
            }];
            double maxScore = ((AGSAddressCandidate *)[sortedCandidates objectAtIndex:0]).score;
            maxScore = maxScore * 0.8;
            AGSMutableEnvelope *totalEnv = nil;
            NSUInteger count = 0;
            EQSAddressCandidatePanelViewController *firstResultVC = nil;
            for (AGSAddressCandidate *c in sortedCandidates) {
                if (c.score >= maxScore)
                {
                    count++;
                    AGSPoint *p = c.location; //c.displayPoint;
                    NSLog(@"Point: %@", p);
                    NSLog(@"Loc  : %@", c.location);
                    AGSGraphic *g = [self.mapView addPoint:p withSymbol:self.mapView.defaultSymbols.findPlace];
                    [g.attributes setObject:@"Geocoded" forKey:@"Source"];
                    [g.attributes addEntriesFromDictionary:c.attributes];

                    if (!totalEnv)
                    {
                        totalEnv = [AGSMutableEnvelope envelopeWithXmin:p.x-1 ymin:p.y-1 xmax:p.x+1 ymax:p.y+1 spatialReference:p.spatialReference];
                    }
                    else
                    {
                        [totalEnv unionWithPoint:p];
                    }
                    
                    EQSAddressCandidatePanelViewController *cvc =
                        [EQSAddressCandidatePanelViewController viewControllerWithCandidate:c
                                                                                OfType:EQSCandidateTypeForwardGeocode];
                    [cvc addToScrollView:self.findPlacesScrollView];
                    [self.geocodeResults addObject:cvc];
                    cvc.candidateViewDelegate = self;
                    cvc.graphic = g;
                    
                    if (!firstResultVC)
                    {
                        firstResultVC = cvc;
                    }
                }
                else
                {
                    break;
                }
            }
            if (firstResultVC)
            {
                [firstResultVC ensureVisibleInParentUIScrollView];
            }
            if (count == 1)
            {
                [self.mapView zoomToLevel:17 withCenterPoint:[totalEnv center] animated:YES];
            }
            else if (totalEnv)
            {
                [totalEnv expandByFactor:1.1];
                [self.mapView zoomToEnvelope:totalEnv animated:YES];
            }
        }
        else
        {
            self.findPlacesNoResultsLabel.hidden = NO;
            AGSEnvelope *constraintEnv = [notification findPlacesSearchExtent];
            if (constraintEnv)
            {
                UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"No results found!"
                                                            message:[NSString stringWithFormat:@"No results were found in the current extent. Try again with no geographic constraint?"]
                                                           delegate:self
                                                  cancelButtonTitle:@"No thanks"
                                                  otherButtonTitles:@"OK", nil];
                objc_setAssociatedObject(v, @"SearchUserInfo", notification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [v show];
            }
        }
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSNotification *notification = objc_getAssociatedObject(alertView, @"SearchUserInfo");
    if (notification)
    {
        if (buttonIndex == 1)
        {
            NSString *searchText = [notification findPlacesSearchString];
            [self.mapView.geoServices findPlaces:searchText];
        }
    }
}

- (void) didFailToGetCandidatesForAddress:(NSNotification *)notification
{
	NSError *error = [notification geoServicesError];
	NSLog(@"Failed to get candidates for address: %@", error);
}

- (void) candidateViewController:(EQSAddressCandidatePanelViewController *)candidateVC
                  DidTapViewType:(EQSCandidateViewType)viewType
{
    AGSPoint *location = candidateVC.candidateLocation;
    if (location)
    {
        [self.mapView centerAtPoint:location animated:YES];

        AGSGraphic *g = candidateVC.graphic;
        if (g)
        {
            [self.mapView showCalloutAtPoint:location forGraphic:g animated:YES];
        }
    }
    [candidateVC ensureVisibleInParentUIScrollView];
}

#pragma mark - Geolocation

- (IBAction)findMe:(id)sender
{
    NSUInteger zoom = [self.mapView getZoomLevel];
	[self.mapView centerAtMyLocationWithZoomLevel:zoom];
}

- (IBAction)findScaleChanged:(id)sender {
    UISlider *slider = sender;
    self.findScale = (NSUInteger)roundf(slider.value);
}

- (IBAction)zoomToLevel:(id)sender {
    [self.mapView zoomToLevel:self.findScale animated:YES];
}

- (void)setFindScale:(NSUInteger)findScale
{
    _findScale = findScale;
    self.findScaleLabel.text = [NSString stringWithFormat:@"%d", _findScale];
}
- (IBAction)messageBarCloseTapped:(id)sender {
    NSLog(@"Close the message bar now...");
    self.messageBar.hidden = YES;
}


#pragma mark - TODO review for removal
# pragma mark - KVO Events

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"KeyPath: %@", keyPath);
}
@end