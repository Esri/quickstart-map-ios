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

#import "AGSStarterGeoServices.h"

#import "AGSMapView+GeneralUtilities.h"
#import "AGSPoint+GeneralUtilities.h"

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

- (IBAction)newPtGraphic:(id)sender;
- (IBAction)newLnGraphic:(id)sender;
- (IBAction)newPgGraphic:(id)sender;
- (IBAction)newMultiPtGraphic:(id)sender;



// Routing UI
@property (weak, nonatomic) IBOutlet UIButton *routeStartButton;
@property (weak, nonatomic) IBOutlet UIButton *routeStopButton;
@property (weak, nonatomic) IBOutlet UILabel *routeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeStopLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearRouteButton;
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
@property (nonatomic, retain) NSString *routeStartAddress;
@property (nonatomic, retain) NSString *routeStopAddress;

@property (nonatomic, assign) NSUInteger findScale;

@property (nonatomic, assign) CGSize keyboardSize;

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
@synthesize clearRouteButton = _clearRouteButton;

@synthesize mapView = _mapView;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

@synthesize uiControlsVisible = _uiControlsVisible;

@synthesize currentState = _currentState;

@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeStopPoint = _routeStopPoint;
@synthesize findScaleLabel = _findScaleLabel;
@synthesize functionToolBar = _functionToolBar;
@synthesize routeStartButton = _routeStartButton;
@synthesize routeStopButton = _routeStopButton;

@synthesize routeResult = _routeResult;

@synthesize findScale = _findScale;

@synthesize basemapVCs = _basemapVCs;

@synthesize keyboardSize = _keyboardSize;

@synthesize routeStartAddress = _routeStartAddress;
@synthesize routeStopAddress = _routeStopAddress;

#define kEDNLiteApplicationLocFromState @"ButtonState"

- (void)initUI
{
	// Track the application state
    self.currentState = EDNVCStateBasemaps;

    // Store some state on the UI so that we can track when the user is placing points for routing.
    objc_setAssociatedObject(self.routeStartButton, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self.routeStopButton, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // When we geolocate, what scale level to zoom the map to?
    self.findScale = 13;
    
    // Go through all the various UI component views, hide them and then place them properly
    // in the UI window so that they'll fade in and out properly.
    for (UIView *v in [self allUIViews]) {
        v.alpha = 0;
        v.hidden = YES;
        v.frame = [self getUIFrameWhenHidden:v];
    }

    // And show the UI by default. Note, at present the UI is always visible.
    self.uiControlsVisible = YES;

    // We want to update the UI when the basemap is changed, so register our interest in a couple
    // of events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapDidChange:) name:@"BasemapDidChange" object:self.mapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(basemapSelected:) name:@"BasemapSelected" object:nil];
    
    self.keyboardSize = CGSizeZero;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // Set up the map UI a little.
    self.mapView.wrapAround = YES;
    self.mapView.touchDelegate = self;
    
    self.routeStartButton.layer.cornerRadius = 5;
    self.routeStopButton.layer.cornerRadius = 5;
    self.clearRouteButton.layer.cornerRadius = 4;
	
	
	self.mapView.defaultRouteStartSymbol = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self updateUIDisplayState:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.keyboardSize = CGSizeZero;
    [self updateUIDisplayState:notification];
}

- (CGPoint) getUIComponentOrigin
{
    CGRect topFrame = self.functionToolBar.frame;
    CGPoint newOrigin = CGPointMake(topFrame.origin.x, topFrame.origin.y + topFrame.size.height);
    return newOrigin;
}

- (CGRect) getUIFrame:(UIView *)viewToDisplay
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
//    CGPoint origin = [self getUIComponentOrigin];
    CGRect viewFrame = viewToDisplay.frame;
    CGPoint origin = CGPointMake(screenFrame.origin.x, screenFrame.size.height - viewFrame.size.height - self.keyboardSize.height);
    CGRect newFrame = CGRectMake(origin.x, origin.y, viewFrame.size.width, viewFrame.size.height);
    return newFrame;
}

- (CGRect) getUIFrameWhenHidden:(UIView *)viewToHide
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
//    CGPoint origin = [self getUIComponentOrigin];
    CGPoint origin = CGPointMake(screenFrame.origin.x, screenFrame.size.height);
    CGSize viewSize = viewToHide.frame.size;
    // Position it to the left of the screen.
    CGRect newFrame = CGRectMake(origin.x, origin.y, viewSize.width, viewSize.height);
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
    [self.mapView centerAtLat:40.7302 Long:-73.9958 withScaleLevel:13];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(gotAddressFromPoint:)
												 name:kEDNLiteGeocodingNotification_AddressFromPointOK
											   object:self.mapView.geoServices];
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

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    NSLog(@"Clicked on map!");
    switch (self.currentState) {
        case EDNVCStateGraphics:
            if (graphics.count > 0)
            {
                // The user selected a graphic. Let's edit it.
                [self.mapView editGraphicFromMapViewDidClickAtPoint:graphics];
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
//    NSLog(@"FilePath: %@", filePath);
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
    [self setFindAddressPanel:nil];
    [self setFindPlacePanel:nil];
    [self setGeolocationPanel:nil];
    [self setGraphicsPanel:nil];
    [self setBasemapListDisplay:nil];
    [self setCurrentBasemapDescriptionWebView:nil];
    [self setEditGraphicsToolbar:nil];
    [self setUndoEditGraphicsButton:nil];
    [self setRedoEditGraphicsButton:nil];
    [self setRouteStartButton:nil];
    [self setRouteStopButton:nil];
    [self setClearRouteButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)addGraphic:(id)sender {
    [self.mapView addPointAtLat:40.7302 Long:-73.9958];
    [self.mapView addLineFromPoints:[NSArray arrayWithObjects:[AGSPoint pointFromLat:40.7302 Long:-73.9958], 
									                          [AGSPoint pointFromLat:41.0 Long:-73.9], nil]];
    [self.mapView addPolygonFromPoints:[NSArray arrayWithObjects:[AGSPoint pointFromLat:40.7302 Long:-73.9958], 
																 [AGSPoint pointFromLat:40.85 Long:-73.65],
																 [AGSPoint pointFromLat:41.0 Long:-73.7],nil]];
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
    [self updateUIDisplayState:nil];
}

- (void)updateUIDisplayState:(NSNotification *)keyboardNotification
{
    NSTimeInterval animationDuration = 0.4;
    UIView *viewToShow = [self getViewToShow];
    NSArray *viewsToHide = [self getViewsToHide];
    
    if (keyboardNotification)
    {
        NSValue *value = [keyboardNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [value getValue:&animationDuration];
    }

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
            [self listenToEditingUndoManager];
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
    
    [self.view endEditing:YES];
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

- (void) setRouteStartAddress:(NSString *)routeStartAddress
{
    _routeStartAddress = routeStartAddress;
    [self setStartText];
}

- (void) setRouteStopAddress:(NSString *)routeStopAddress
{
    _routeStopAddress = routeStopAddress;
    [self setStopText];
}

- (void) gotAddressFromPoint:(NSNotification *)notification
{	
	NSDictionary *userInfo = notification.userInfo;
	
	NSOperation *op = [userInfo objectForKey:kEDNLiteGeocodingNotification_AddressFromPoint_WorkerOperationKey];
	
	if (op)
	{
		NSString *source = objc_getAssociatedObject(op, @"SOURCE");
		if (source)
		{
			// OK, this is something we requested and so we should be able to work
			// out what to do with it.
			
			AGSAddressCandidate *candidate = [userInfo objectForKey:kEDNLiteGeocodingNotification_AddressFromPoint_AddressCandidateKey];
			
			NSDictionary *ad = candidate.address;
			NSString *street = [ad objectForKey:@"Address"];
			if (street != (id)[NSNull null])
			{
				street = [NSString stringWithFormat:@"%@, ", street];
			}
			else {
				street = @"";
			}
			NSString *address = [NSString stringWithFormat:@"%@%@, %@ %@",
								 street,
								 [ad objectForKey:@"City"],
								 [ad objectForKey:@"State"],
								 [ad objectForKey:@"Zip"]];
			
			if ([source isEqualToString:@"START"])
			{
				self.routeStartAddress = address;
			}
			else if ([source isEqualToString:@"STOP"])
			{
				self.routeStopAddress = address;
			}
		}
	}
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
	NSLog(@"Failed to get address for location: %@", error);
}

- (void) setStartText
{
    NSString *latLongText = nil;
    if (self.routeStartPoint)
    {
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromPoint:self.routeStartPoint];
        latLongText = [NSString stringWithFormat:@"%.4f,%.4f", wgs84Pt.y, wgs84Pt.x];
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

- (void) setStopText
{
    NSString *latLongText = nil;
    if (self.routeStopPoint)
    {
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromPoint:self.routeStopPoint];
        latLongText = [NSString stringWithFormat:@"%.4f,%.4f", wgs84Pt.y, wgs84Pt.x];
    }
    NSString *address = self.routeStopAddress;
    if (latLongText && address)
    {
        self.routeStopLabel.text = [NSString stringWithFormat:@"%@ (%@)", address, latLongText];
    }
    else if (latLongText)
    {
        self.routeStopLabel.text = latLongText;
    }
    else {
        self.routeStopLabel.text = address;
    }
}

- (void) setRouteStartPoint:(AGSPoint *)routeStartPoint
{
    _routeStartPoint = routeStartPoint;
    if (_routeStartPoint)
    {
		self.currentState = EDNVCStateDirections;
        [self setToFromButton:self.routeStartButton selectedState:NO];
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromPoint:_routeStartPoint];
        NSOperation *op = [self.mapView getAddressForMapPoint:wgs84Pt withDelegate:self];
        objc_setAssociatedObject(op, @"SOURCE", @"START", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self doRouteIfPossible];
    }
    [self setStartText];
}

- (void) setRouteStopPoint:(AGSPoint *)routeStopPoint
{
    _routeStopPoint = routeStopPoint;
    if (_routeStopPoint)
    {
		self.currentState = EDNVCStateDirections;
        [self setToFromButton:self.routeStopButton selectedState:NO];
        AGSPoint *wgs84Pt = [EDNLiteHelper getWGS84PointFromPoint:_routeStopPoint];
        NSOperation *op = [self.mapView getAddressForMapPoint:wgs84Pt withDelegate:self];
        objc_setAssociatedObject(op, @"SOURCE", @"STOP", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self doRouteIfPossible];
	}
    [self setStopText];
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

- (void)setToFromButton:(UIButton *)bi selectedState:(BOOL)selected
{
    // Clear the other button regardless of the new state for this one.
    UIButton *otherBi = (bi == self.routeStartButton)?self.routeStopButton:self.routeStartButton;
//    otherBi.tintColor = nil;
    otherBi.selected = NO;
//    UIColor *tintColor = (bi == self.routeStartButton)?[UIColor greenColor]:[UIColor redColor];
    objc_setAssociatedObject(otherBi, kEDNLiteApplicationLocFromState, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Set the new state for this one, and set our app state too.
    NSLog(@"Selected: %@", selected?@"YES":@"NO");
    bi.selected = selected;
    if (selected)
    {
//        bi.tintColor = [UIColor colorWithWhite:0.6 alpha:1];
//        bi.tintColor = tintColor;
        self.currentState = (bi == self.routeStartButton)?EDNVCStateDirections_WaitingForRouteStart:EDNVCStateDirections_WaitingForRouteStop;
    }
    else
    {
//        bi.tintColor = nil;
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

- (IBAction)newPtGraphic:(id)sender {
    [self.mapView editNewPoint];
    self.currentState = EDNVCStateGraphics_Editing;
}

- (IBAction)newLnGraphic:(id)sender {
    [self.mapView editNewLine];
    self.currentState = EDNVCStateGraphics_Editing;
}

- (IBAction)newPgGraphic:(id)sender {
    [self.mapView editNewPolygon];
    self.currentState = EDNVCStateGraphics_Editing;
}

- (IBAction)newMultiPtGraphic:(id)sender {
    [self.mapView editNewMultipoint];
    self.currentState = EDNVCStateGraphics_Editing;
}
@end