//
//  EQSSampleViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSSampleViewController.h"
#import "EQSPortalItemPickerView.h"

#import "EQSHelper.h"

#import	"AGSMapView+Navigation.h"
#import "AGSMapView+Basemaps.h"
#import "AGSMapView+Graphics.h"
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
#define kEQSGetAddressReasonRouteStart @"RouteStartPoint"
#define kEQSGetAddressReasonRouteEnd @"RouteEndPoint"
#define kEQSGetAddressReasonReverseGeocodeForPoint @"FindAddressFunction"
#define kEQSGetAddressReason_AddressForGeolocation @"AddressForGeolocation"

@interface EQSSampleViewController ()
                                        <AGSPortalItemDelegate,
                                        AGSMapViewTouchDelegate,
                                        AGSRouteTaskDelegate,
                                        UISearchBarDelegate,
                                        AGSLocatorDelegate,
                                        UIWebViewDelegate,
                                        EQSBasemapPickerDelegate,
                                        AGSMapViewCalloutDelegate>

// General UI
@property (weak, nonatomic) IBOutlet UIToolbar *functionToolBar;
@property (weak, nonatomic) IBOutlet UIView *routingPanel;
@property (weak, nonatomic) IBOutlet UIView *findPlacePanel;
@property (weak, nonatomic) IBOutlet UIView *cloudDataPanel;
@property (weak, nonatomic) IBOutlet UIView *geolocationPanel;
@property (weak, nonatomic) IBOutlet UIView *graphicsPanel;

@property (weak, nonatomic) IBOutlet UIView *messageBar;
@property (weak, nonatomic) IBOutlet UILabel *messageBarLabel;
- (IBAction)messageBarCloseTapped:(id)sender;

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

@property (weak, nonatomic) IBOutlet UIButton *graphicPointButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicLineButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicPolygonButton;

- (IBAction)doneEditingGraphic:(id)sender;
- (IBAction)cancelEditingGraphic:(id)sender;
- (IBAction)undoEditingGraphic:(id)sender;
- (IBAction)redoEditingGraphic:(id)sender;
- (IBAction)zoomToEditingGeometry:(id)sender;

- (IBAction)newPtGraphic:(id)sender;
- (IBAction)newLnGraphic:(id)sender;
- (IBAction)newPgGraphic:(id)sender;
- (IBAction)newMultiPtGraphic:(id)sender;



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
@property (nonatomic, retain) AGSRouteResult *routeResult;

@property (strong, nonatomic) IBOutlet EQSRouteResultsView *routeResultsView;

// Geolocation UI
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UILabel *myLocationAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *findScaleLabel;

// Non UI Properties
@property (assign) EQSBasemapType currentBasemapType;
@property (assign) BOOL uiControlsVisible;

@property (assign) EQSSampleAppState currentState;

@property (nonatomic, assign) NSUInteger findScale;

@property (nonatomic, assign) CGSize keyboardSize;

// Find Places
@property (weak, nonatomic) IBOutlet UIToolbar *findToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *findbutton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIScrollView *findPlacesScrollView;
@property (weak, nonatomic) IBOutlet UILabel *findPlacesNoResultsLabel;

@property (nonatomic, strong) id<AGSInfoTemplateDelegate> geocodeInfoTemplateDelegate;

@property (weak, nonatomic) IBOutlet EQSCodeView *codeViewer;
- (IBAction)findPlacesTapped:(id)sender;


// Actions
- (IBAction)addGraphics:(id)sender;

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

@implementation EQSSampleViewController
@synthesize editGraphicsToolbar = _editGraphicsToolbar;
@synthesize undoEditGraphicsButton = _undoEditGraphicsButton;
@synthesize redoEditGraphicsButton = _redoEditGraphicsButton;
@synthesize graphicPointButton = _graphicPointButton;
@synthesize graphicLineButton = _graphicLineButton;
@synthesize graphicPolygonButton = _graphicPolygonButton;
@synthesize geolocationPanel = _geolocationPanel;
@synthesize graphicsPanel = _graphicsPanel;
@synthesize messageBar = _messageBar;
@synthesize messageBarLabel = _messageBarLabel;
@synthesize basemapsPicker = _basemapsPicker;
@synthesize graphicButton = _graphicButton;
@synthesize clearPointsButton = _clearPointsButton;
@synthesize clearLinesButton = _clearLinesButton;
@synthesize clearPolysButton = _clearPolysButton;
@synthesize routingPanel = _routingPanel;
@synthesize findPlacePanel = _findAddressPanel;
@synthesize findAddressSearchBar = _findAddressSearchBar;
@synthesize cloudDataPanel = _findPlacePanel;
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
@synthesize myLocationAddressLabel = _myLocationAddressLabel;
@synthesize functionToolBar = _functionToolBar;
@synthesize routeStartButton = _routeStartButton;
@synthesize routeEndButton = _routeStopButton;

@synthesize routeResult = _routeResult;
@synthesize routeResultsView = _routeResultsView;

@synthesize findScale = _findScale;

@synthesize basemapVCs = _basemapVCs;

@synthesize keyboardSize = _keyboardSize;
@synthesize findToolbar = _findToolbar;
@synthesize findbutton = _findbutton;
@synthesize cancelButton = _cancelButton;
@synthesize findPlacesScrollView = _findPlacesScrollView;
@synthesize findPlacesNoResultsLabel = _findPlacesNoResultsLabel;
@synthesize codeViewer = _codeViewer;

@synthesize geocodeInfoTemplateDelegate = _geocodeInfoTemplateDelegate;

#define kEQSApplicationLocFromState @"ButtonState"

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
    
	// Track the application state
    self.currentState = EQSSampleAppStateBasemaps;

	[self initBasemapPicker];
    
    // Initialize the default symbols container. This will load them in the background (some are URL based,
    // which causes a synchronous HTTP request to block the initializer UIImage initializer).
    id tmp = self.mapView.defaultSymbols;
    tmp = nil;

    // Store some state on the UI so that we can track when the user is placing points for routing.
    objc_setAssociatedObject(self.routeStartButton, kEQSApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self.routeEndButton, kEQSApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // Set up the map UI a little.
    self.mapView.wrapAround = YES;
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    
    self.findMeButton.layer.cornerRadius = 5;
    self.routeStartButton.layer.cornerRadius = 5;
    self.routeEndButton.layer.cornerRadius = 5;
    self.clearRouteButton.layer.cornerRadius = 4;
    
    self.graphicPointButton.layer.cornerRadius = 5;
    self.graphicLineButton.layer.cornerRadius = 5;
    self.graphicPolygonButton.layer.cornerRadius = 5;
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
    [self.mapView centerAtLat:40.7302 Lon:-73.9958 withScaleLevel:13];

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
    [self setCancelButton:nil];
    [self setFindToolbar:nil];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - AGSMapView Events

- (void)mapView:(AGSMapView *)mapView didShowCalloutForGraphic:(AGSGraphic *)graphic
{
    NSLog(@"Showed callout");
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint graphics:(NSDictionary *)graphics
{
    NSLog(@"Clicked on map!");
    switch (self.currentState) {
        case EQSSampleAppStateGraphics:
            if (graphics.count > 0)
            {
                // The user selected a graphic. Let's edit it.
                [self.mapView editGraphicFromMapViewDidClickAtPoint:graphics];
                self.currentState = EQSSampleAppStateGraphics_Editing;
            }
            break;

        case EQSSampleAppStateDirections_WaitingForRouteStart:
            [self didTapStartPoint:mapPoint];
            break;
            
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            [self didTapEndPoint:mapPoint];
            break;
            
        case EQSSampleAppStateFindPlace:
            [self didTapToReverseGeocode:mapPoint];
            break;
            
        default:
            NSLog(@"Click on %d graphics", graphics.count);
            for (id key in graphics.allKeys) {
                NSLog(@"Graphic '%@' = %@", key, [graphics objectForKey:key]);
            }
            break;
    }
}

#pragma mark - Keyboard Events

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"Keyboard will show: %@", NSStringFromCGSize(self.keyboardSize));
    [self updateUIDisplayState:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardSize = CGSizeZero;
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
            break;
        case EQSSampleAppStateDirections_WaitingForRouteStart:
            self.routeStartLabel.text = @"Tap a point on the map…";
			self.routeStartButton.selected = YES;
			self.routeEndButton.selected = NO;
            break;
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            self.routeEndLabel.text = @"Tap a point on the map…";
			self.routeEndButton.selected = YES;
			self.routeStartButton.selected = NO;
            break;
            
        case EQSSampleAppStateGraphics_Editing:
            for (UIBarButtonItem *buttonItem in self.editGraphicsToolbar.items) {
                buttonItem.enabled = YES;
            }
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
            self.currentState = EQSSampleAppStateDirections;
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
                               self.cloudDataPanel,
                               self.graphicsPanel, nil];
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
//                             viewToAnimateOut.frame = [self getUIFrameWhenHidden:viewToAnimateOut ];
                         }
                         completion:^(BOOL finished) {
                             viewToAnimateOut.hidden = YES;
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }];
        
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

- (void) setUndoRedoButtonStates
{
    [self setUndoRedoButtonStatesForUndoManager:[self.mapView getUndoManagerForGraphicsEdits]];
}

- (void) editUndoRedoChanged:(NSNotification *)notification
{
    NSUndoManager *um = notification.object;
    [self setUndoRedoButtonStatesForUndoManager:um];
}

- (void)listenToEditingUndoManager
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"NSUndoManagerDidCloseUndoGroupNotification" 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"NSUndoManagerDidUndoChangeNotification" 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"NSUndoManagerDidRedoChangeNotification" 
                                                  object:nil];
    
    NSUndoManager *um = [self.mapView getUndoManagerForGraphicsEdits];
    if (um)
    {
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
    }
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
    AGSPortalItem *pi = [notification.userInfo objectForKey:@"PortalItem"];
    EQSBasemapType basemapType = [(NSNumber *)[notification.userInfo objectForKey:@"BasemapType"] intValue];
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
    [self.mapView addPointAtLat:40.7302 Long:-73.9958];
    [self.mapView addLineFromPoints:[NSArray arrayWithObjects:[AGSPoint pointFromLat:40.7302 Lon:-73.9958],
									 [AGSPoint pointFromLat:41.0 Lon:-73.9], nil]];
    [self.mapView addPolygonFromPoints:[NSArray arrayWithObjects:[AGSPoint pointFromLat:40.7302 Lon:-73.9958],
										[AGSPoint pointFromLat:40.85 Lon:-73.65],
										[AGSPoint pointFromLat:41.0 Lon:-73.7],nil]];
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
    [self.mapView saveCurrentEdit];
    self.currentState = EQSSampleAppStateGraphics;
}

- (IBAction)cancelEditingGraphic:(id)sender {
    [self.mapView cancelCurrentEdit];
    self.currentState = EQSSampleAppStateGraphics;
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

#pragma mark - Geocoding
- (void) didGetAddressFromPoint:(NSNotification *)notification
{
	NSDictionary *userInfo = notification.userInfo;
	NSOperation *op = [userInfo objectForKey:kEQSGeoServicesNotification_WorkerOperationKey];
	
	if (op)
	{
		AGSAddressCandidate *candidate = [userInfo objectForKey:kEQSGeoServicesNotification_AddressFromPoint_AddressCandidateKey];
		
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
			
			if ([source isEqualToString:kEQSGetAddressReasonRouteStart])
			{
				self.routeStartPoint = candidate.location;
				self.routeStartAddress = address;
			}
			else if ([source isEqualToString:kEQSGetAddressReasonRouteEnd])
			{
				self.routeEndPoint = candidate.location;
				self.routeEndAddress = address;
			}
			else if ([source isEqualToString:kEQSGetAddressReasonReverseGeocodeForPoint])
			{
				self.findAddressSearchBar.text = address;
			}
            else if ([source isEqualToString:kEQSGetAddressReason_AddressForGeolocation])
            {
                self.myLocationAddressLabel.text = address;
            }
		}
	}
}

- (void) didFailToGetAddressFromPoint:(NSNotification *)notification
{
	NSError *error = [notification.userInfo objectForKey:kEQSGeoServicesNotification_ErrorKey];
	NSLog(@"Failed to get address for location: %@", error);
}

#pragma mark - Directions

- (void)registerForGeoServicesNotifications
{
	// Let me know when the Geoservices object finds an address for a point.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didGetAddressFromPoint:)
												 name:kEQSGeoServicesNotification_AddressFromPoint_OK
											   object:self.mapView.geoServices];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFailToGetAddressFromPoint:)
												 name:kEQSGeoServicesNotification_AddressFromPoint_Error
											   object:self.mapView.geoServices];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSolveRouteOK:)
												 name:kEQSGeoServicesNotification_FindRoute_OK
											   object:self.mapView.geoServices];
	
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
    // And let me know when it finds points for an address.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToGetCandidatesForAddress:)
                                                 name:kEQSGeoServicesNotification_PointsFromAddress_Error
                                               object:self.mapView.geoServices];
    
    
    // Geolocation Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGeolocate:)
                                                 name:kEQSGeoServicesNotification_Geolocation_OK
                                               object:self.mapView.geoServices];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToGeolocate:)
                                                 name:kEQSGeoServicesNotification_Geolocation_Error
                                               object:self.mapView.geoServices];
}

- (void) didGeolocate:(NSNotification *)notification
{
    CLLocation *location = [notification geolocation];
    
    if (location)
    {
        self.myLocationAddressLabel.text = location.description;
        AGSPoint *locPt = [AGSPoint pointFromLat:location.coordinate.latitude Lon:location.coordinate.longitude];
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

- (void)didTapStartPoint:(AGSPoint *)mapPoint
{
    NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReasonRouteStart, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTapEndPoint:(AGSPoint *)mapPoint
{
    NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReasonRouteEnd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTapToReverseGeocode:(AGSPoint *)mapPoint
{
	NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReasonReverseGeocodeForPoint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        NSLog(@"Start and end points set...");
        [self.mapView.geoServices findDirectionsFrom:self.routeStartPoint To:self.routeEndPoint];
        return YES;
    }
    return NO;
}

- (void) didSolveRouteOK:(NSNotification *)notification
{
    NSLog(@"Entered didSolveRouteOK");

	AGSRouteTaskResult *results = [notification routeTaskResults];
    NSLog(@"Got UserInfo");
	if (results)
	{
		self.routeResult = [results.routeResults objectAtIndex:0];
        NSLog(@"Showing results");
		[self.mapView.routeDisplayHelper showRouteResults:results];
        NSLog(@"Showed results");
        EQSRouteResultsViewController *rrvc = self.routeResultsView.viewController;
        rrvc.routeResult = [results.routeResults objectAtIndex:0];
        
//        AGSGraphic *routeGraphic = rrvc.routeResult.routeGraphic;
//        AGSGeometry *routeGeom = routeGraphic.geometry;
//        AGSEnvelope *routeEnv = routeGeom.envelope;
//        AGSEnvelope *newEnv = [self.mapView getEnvelopeToFitViewAspectRatio:routeEnv];
//        NSLog(@"%@\n%@",routeEnv, newEnv);
//        
//        CGRect rectToZoomTo = [self.mapView getMinOrthoVisibleArea];
	}
}

- (void) didFailToSolveRoute:(NSNotification *)notification
{
	NSError *error = [notification.userInfo objectForKey:kEQSGeoServicesNotification_ErrorKey];
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

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
    self.routeResult = [routeTaskResult.routeResults objectAtIndex:0];
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
    else {
        self.routeStartLabel.text = address;
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
    else {
        self.routeEndLabel.text = address;
    }
}

- (IBAction)clearRoute:(id)sender {
    if (self.routeResult)
    {
        self.routeResult = nil;
        [self.mapView.routeDisplayHelper clearRouteDisplay];
        self.routeResultsView.viewController.routeResult = nil;
		self.routeStartAddress = nil;
		self.routeEndAddress = nil;
        self.routeStartPoint = nil;
        self.routeEndPoint = nil;
        self.currentState = EQSSampleAppStateDirections_WaitingForRouteStart;
    }
}

- (void)setToFromButton:(UIButton *)bi selectedState:(BOOL)selected
{
    // Clear the other button regardless of the new state for this one.
    UIButton *otherBi = (bi == self.routeStartButton)?self.routeEndButton:self.routeStartButton;
	//    otherBi.tintColor = nil;
    otherBi.selected = NO;
	//    UIColor *tintColor = (bi == self.routeStartButton)?[UIColor greenColor]:[UIColor redColor];
    objc_setAssociatedObject(otherBi, kEQSApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
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
    objc_setAssociatedObject(bi, kEQSApplicationLocFromState, [NSNumber numberWithBool:selected], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IBAction)toFromTapped:(id)sender {
    BOOL selected = [(NSNumber *)objc_getAssociatedObject(sender, kEQSApplicationLocFromState) boolValue];
    [self setToFromButton:sender selectedState:!selected];
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
	NSLog(@"Searching for: %@", searchString);
    AGSPolygon *v = self.mapView.visibleArea;
    AGSEnvelope *env = v.envelope;
	[self.mapView.geoServices findPlaces:searchString withinEnvelope:env];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSArray *currentItems = self.findToolbar.items;
    NSMutableArray *newItems = [NSMutableArray array];
    for (UIBarButtonItem *bbi in currentItems) {
        if (bbi != self.findbutton &&
            bbi != self.cancelButton)
        {
            [newItems addObject:bbi];
        }
    }
    
    [newItems addObject:self.cancelButton];
    
    [self.findToolbar setItems:newItems animated:YES];
    
    return YES;
}

- (BOOL) searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSArray *currentItems = self.findToolbar.items;
    NSMutableArray *newItems = [NSMutableArray array];
    for (UIBarButtonItem *bbi in currentItems) {
        if (bbi != self.findbutton &&
            bbi != self.cancelButton)
        {
            [newItems addObject:bbi];
        }
    }
    
    [newItems addObject:self.findbutton];
    
    [self.findToolbar setItems:newItems animated:YES];
    
    return YES;
}

- (id<AGSInfoTemplateDelegate>) geocodeInfoTemplateDelegate
{
    if (!_geocodeInfoTemplateDelegate)
    {
        AGSCalloutTemplate *template = [[AGSCalloutTemplate alloc] init];
        template.detailTemplate = @"Stuff goes here\nAnd here";
        template.titleTemplate = @"${Addr_Type}";
        _geocodeInfoTemplateDelegate = template;
    }
    return _geocodeInfoTemplateDelegate;
}

- (void) gotCandidatesForAddress:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSOperation *op = [userInfo objectForKey:kEQSGeoServicesNotification_WorkerOperationKey];
	
    if (op)
    {
        // First, let's remove all the old items (if any)
        [self.mapView removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *g) {
            if ([g.attributes objectForKey:@"Source"])
            {
                NSLog(@"Removing graphic!");
                return YES;
            }
            return NO;
        }];
        
        for (UIView *subView in self.findPlacesScrollView.subviews) {
            [subView removeFromSuperview];
        }
        
        NSArray *candidates = [userInfo objectForKey:kEQSGeoServicesNotification_PointsFromAddress_LocationCandidatesKey];
        EQSAddressCandidateView *prevView = nil;
        if (candidates.count > 0)
        {
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
            for (AGSAddressCandidate *c in sortedCandidates) {
                if (c.score >= maxScore)
                {
                    count++;
                    AGSPoint *p = [c.location getWebMercatorAuxSpherePoint];
                    AGSGraphic *g = [self.mapView addPoint:p];
                    [g.attributes setObject:@"Geocoded" forKey:@"Source"];
                    [g.attributes addEntriesFromDictionary:c.attributes];
//                    g.infoTemplateDelegate = self.geocodeInfoTemplateDelegate;
                    NSLog(@"Address found: %@", g.attributes);
                    if (!totalEnv)
                    {
                        totalEnv = [AGSMutableEnvelope envelopeWithXmin:p.x-1 ymin:p.y-1 xmax:p.x+1 ymax:p.y+1 spatialReference:p.spatialReference];
                    }
                    else
                    {
                        [totalEnv unionWithPoint:p];
                    }
                    
                    EQSAddressCandidateView *candidateView = [[EQSAddressCandidateView alloc] init];
                    [candidateView.viewController addToParentView:self.findPlacesScrollView relativeTo:prevView];
                    candidateView.viewController.candidate = c;
                    prevView = candidateView;
                    
                    EQSAddressCandidateView *candidatePopupView = [[EQSAddressCandidateView alloc] init];
                    candidatePopupView.viewController.candidate = c;
                    g.infoTemplateDelegate = candidatePopupView.viewController;
                }
                else
                {
                    break;
                }
            }
            [EQSAddressCandidateViewController setContentWidthOfScrollViewContainingCandidateViews:self.findPlacesScrollView UsingTemplate:prevView];
            prevView = nil;
            if (count == 1)
            {
                [self.mapView centerAtPoint:[totalEnv center] withScaleLevel:17];
            }
            else if (totalEnv)
            {
                [self.mapView zoomToEnvelope:totalEnv animated:YES];
            }
        }
        else
        {
            self.findPlacesNoResultsLabel.hidden = NO;
        }
    }
}

- (void) didFailToGetCandidatesForAddress:(NSNotification *)notification
{
	NSError *error = [notification.userInfo objectForKey:kEQSGeoServicesNotification_ErrorKey];
	NSLog(@"Failed to get candidates for address: %@", error);
}

#pragma mark - Geolocation

- (IBAction)findMe:(id)sender
{
	[self.mapView centerAtMyLocationWithScaleLevel:16];
}

- (IBAction)findScaleChanged:(id)sender {
    UISlider *slider = sender;
    self.findScale = (NSUInteger)roundf(slider.value);
}

- (IBAction)zoomToLevel:(id)sender {
    [self.mapView zoomToLevel:self.findScale];
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