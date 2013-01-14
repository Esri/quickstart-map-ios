//
//  EQSSampleViewController.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <EsriQuickStart/EsriQuickStart.h>

#import "EQSSampleViewController.h"

#import "EQSPortalItemPickerView.h"
#import "EQSSampleAppStateEnums.h"
#import "EQSCodeView.h"
#import "EQSSearchResultView.h"
#import "UIApplication+AppDimensions.h"

#import "EQSBasemapPickerView.h"
#import "EQSBasemapDetailsViewController.h"

#import "MBProgressHUD.h"

#import <objc/runtime.h>

typedef enum {
	EQSSampleAppMessageStateNormal,
	EQSSampleAppMessageStateHidden,
	EQSSampleAppMessageStateHighlight,
	EQSSampleAppMessageStateAlert
} EQSSampleAppMessageState;

@interface EQSSampleViewController ()  <AGSMapViewTouchDelegate,
                                        AGSMapViewCalloutDelegate,
                                        EQSBasemapPickerDelegate,
										EQSSearchResultViewDelegate,
                                        EQSCodeViewControllerDelegate,
                                        UISearchBarDelegate,
                                        UIWebViewDelegate,
                                        UIAlertViewDelegate>

#pragma mark - Function Selection UI
// In the iPhone we use a NavBar. On the iPad it's a Toolbar.
@property (weak, nonatomic) IBOutlet UINavigationBar *functionNavBar_iPhone;
@property (weak, nonatomic) IBOutlet UIToolbar *functionToolBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *functionSegControl;
@property (strong, nonatomic) NSArray *functionSelectedImages;
@property (strong, nonatomic) NSArray *functionDefaultImages;
- (IBAction)functionChanged:(id)sender;


#pragma mark - Function UI containers
// UIViews serve as panels for each function's main interface.
@property (weak, nonatomic) IBOutlet UIView *routingPanel;
@property (weak, nonatomic) IBOutlet UIView *findPlacePanel;
@property (weak, nonatomic) IBOutlet UIView *cloudDataPanel;
@property (weak, nonatomic) IBOutlet UIView *geolocationPanel;
@property (weak, nonatomic) IBOutlet UIView *graphicsEditPanel;
@property (weak, nonatomic) IBOutlet UIView *graphicsCreatePanel;


#pragma mark - UI Mode
// Control to restore the UI when in full screen mode.
@property (weak, nonatomic) IBOutlet UIButton *showUIButton;
- (IBAction)resizeUIGoFullScreen:(id)sender;
- (IBAction)resizeUIExitFullScreen:(id)sender;


#pragma mark - User messages display
@property (weak, nonatomic) IBOutlet UIView *messageBar;
@property (weak, nonatomic) IBOutlet UILabel *messageBarLabel;
@property (weak, nonatomic) IBOutlet UIView *messageBarAlertBackdrop;
- (IBAction)messageBarCloseTapped:(id)sender;


#pragma mark - Keyboard mask
@property (weak, nonatomic) IBOutlet UIButton *cancelKeyboardButton;
- (IBAction)cancelKeyboardPressed:(id)sender;




#pragma mark - Basemaps UI
@property (weak, nonatomic) IBOutlet EQSBasemapPickerView *basemapsPicker;


#pragma mark - Graphics UI
@property (weak, nonatomic) IBOutlet UIToolbar *editGraphicsToolbar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoEditGraphicsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoEditGraphicsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteGraphicButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomToGraphicButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveEditsGraphicsButton;

@property (weak, nonatomic) IBOutlet UIButton *graphicPointButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicLineButton;
@property (weak, nonatomic) IBOutlet UIButton *graphicPolygonButton;

#pragma mark - Graphics Creation
- (IBAction)createNewPtGraphic:(id)sender;
- (IBAction)createNewLnGraphic:(id)sender;
- (IBAction)createNewPgGraphic:(id)sender;

#pragma mark - Graphics Editing
- (IBAction)saveGraphicsEdit:(id)sender;
- (IBAction)cancelGraphicsEdit:(id)sender;
- (IBAction)undoGraphicsEdit:(id)sender;
- (IBAction)redoGraphicsEdit:(id)sender;

- (IBAction)deleteSelectedGraphic:(id)sender;
- (IBAction)zoomToEditGeometry:(id)sender;


#pragma mark - Directions UI
@property (weak, nonatomic) IBOutlet UIButton *routeStartButton;
@property (weak, nonatomic) IBOutlet UIButton *routeEndButton;
@property (weak, nonatomic) IBOutlet UILabel *routeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeEndLabel;

@property (weak, nonatomic) IBOutlet UITextField *routeFromTextField;
@property (weak, nonatomic) IBOutlet UITextField *routeToTextField;

@property (weak, nonatomic) IBOutlet UIView *routeFromLeftView;
@property (weak, nonatomic) IBOutlet UIView *routeToLeftView;

@property (strong, nonatomic) IBOutlet EQSRouteResultsView *routeResultsView;
- (IBAction)toFromTapped:(id)sender;
- (IBAction)swapRouteStartAndEnd:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *directionsStartContainerView;
@property (weak, nonatomic) IBOutlet UIView *directionsEndContainerView;


#pragma mark - Geolocation UI
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UILabel *myLocationAddressLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *findMeScrollView;
- (IBAction)findMe:(id)sender;


#pragma mark - Find Places UI
@property (weak, nonatomic) IBOutlet UISearchBar *findPlacesSearchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *findButton;
@property (weak, nonatomic) IBOutlet UIScrollView *findPlacesScrollView;
@property (weak, nonatomic) IBOutlet UILabel *findPlacesNoResultsLabel;
- (IBAction)findPlacesTapped:(id)sender;


#pragma mark - Code Display
@property (weak, nonatomic) IBOutlet EQSCodeView *codeViewer;




#pragma mark - Application State
@property (assign) EQSSampleAppState currentState;


#pragma mark - Message Bar State
@property (nonatomic, strong) NSString *userMessage;
@property (nonatomic, assign) EQSSampleAppMessageState messageState;


#pragma mark - UI State
@property (assign) BOOL uiControlsVisible;
@property (nonatomic, assign) CGSize keyboardSize;


#pragma mark - Basemap State
@property (nonatomic, retain) AGSPortalItem *currentPortalItem;
@property (assign) EQSBasemapType currentBasemapType;


#pragma mark - Directions data
@property (nonatomic, strong) AGSPoint *routeStartPoint;
@property (nonatomic, strong) AGSPoint *routeEndPoint;
@property (nonatomic, retain) NSString *routeStartAddress;
@property (nonatomic, retain) NSString *routeEndAddress;


#pragma mark - Geocode storage
@property (nonatomic, strong) NSMutableOrderedSet *geocodeResults;
@property (nonatomic, strong) NSMutableOrderedSet *geolocationResults;
@end




#pragma mark - Geocoding Tracking Constants
#define kEQSGetAddressReasonKey @"FindAddressReason"
#define kEQSGetAddressReason_RouteStart @"RouteStartPoint"
#define kEQSGetAddressReason_RouteEnd @"RouteEndPoint"
#define kEQSGetAddressReason_ReverseGeocodeForPoint @"FindAddressFunction"
#define kEQSGetAddressReason_AddressForGeolocation @"AddressForGeolocation"
#define kEQSGetAddressData_SearchPoint @"EQSGeoServices_ReverseGeocode_Data_SearchPoint"



@implementation EQSSampleViewController
@synthesize mapView = _mapView;

@synthesize geolocationPanel = _geolocationPanel;
@synthesize graphicsEditPanel = _graphicsPanel;
@synthesize graphicsCreatePanel = _graphicsCreatePanel;
@synthesize routingPanel = _routingPanel;
@synthesize findPlacePanel = _findPlacePanel;
@synthesize cloudDataPanel = _cloudDataPanel;

@synthesize editGraphicsToolbar = _editGraphicsToolbar;
@synthesize undoEditGraphicsButton = _undoEditGraphicsButton;
@synthesize redoEditGraphicsButton = _redoEditGraphicsButton;
@synthesize deleteGraphicButton = _deleteGraphicButton;
@synthesize zoomToGraphicButton = _zoomToGraphicButton;
@synthesize saveEditsGraphicsButton = _saveEditsGraphicsButton;
@synthesize graphicPointButton = _graphicPointButton;
@synthesize graphicLineButton = _graphicLineButton;
@synthesize graphicPolygonButton = _graphicPolygonButton;

@synthesize functionSegControl = _functionSegControl;

@synthesize showUIButton = _buttonShowUI;

@synthesize messageBar = _messageBar;
@synthesize messageBarLabel = _messageBarLabel;
@synthesize messageBarAlertBackdrop = _messageBarAlertBackdrop;

@synthesize basemapsPicker = _basemapsPicker;

@synthesize cancelKeyboardButton = _cancelKeyboardButton;
@synthesize findPlacesSearchBar = _findAddressSearchBar;

@synthesize routeStartLabel = _routeStartLabel;
@synthesize routeEndLabel = _routeStopLabel;
@synthesize routeFromTextField = _routeFromTextField;
@synthesize routeToTextField = _routeToTextField;
@synthesize routeFromLeftView = _routeFromLeftView;
@synthesize routeToLeftView = _routeToLeftView;
@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeEndPoint = _routeEndPoint;
@synthesize routeStartAddress = _routeStartAddress;
@synthesize routeEndAddress = _routeEndAddress;

@synthesize currentPortalItem = _currentPortalItem;
@synthesize currentBasemapType = _currentBasemapType;

@synthesize uiControlsVisible = _uiControlsVisible;


@synthesize currentState = _currentState;
@synthesize messageState = _messageState;
@synthesize userMessage = _userMessage;


@synthesize findMeButton = _findMeButton;
@synthesize findMeScrollView = _findMeScrollView;
@synthesize myLocationAddressLabel = _myLocationAddressLabel;
@synthesize functionNavBar_iPhone = _functionNavBar_iPhone;
@synthesize functionToolBar = _functionToolBar;
@synthesize routeStartButton = _routeStartButton;
@synthesize routeEndButton = _routeStopButton;

@synthesize routeResultsView = _routeResultsView;

@synthesize keyboardSize = _keyboardSize;
@synthesize findButton = _findbutton;
@synthesize findPlacesScrollView = _findPlacesScrollView;
@synthesize findPlacesNoResultsLabel = _findPlacesNoResultsLabel;
@synthesize codeViewer = _codeViewer;

@synthesize geocodeResults = _geocodeResults;
@synthesize geolocationResults = _geolocationResults;


#pragma mark - UIView Events
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepUI];
	[self initApp];
	[self initUI];

	// Set up our map with a basemap, and jump to a location and scale level.
    [self.mapView setBasemap: self.currentBasemapType];
    [self.mapView zoomToPlace:@"New York" animated:YES];

	[self registerForGeoServicesNotifications];
}

//    AGSPoint *nyc = [AGSPoint pointFromLat:40.7302 Lon:-73.9958];
//    [self.mapView centerAtPoint:nyc withScaleLevel:0];
//    [self.mapView centerAtLat:40.7302 Long:-73.9958];
//    [self.mapView zoomToLevel:7];
//    [self.mapView zoomToLevel:13 withLat:40.7302 lon:-73.9958 animated:YES];
//    [self.mapView centerAtMyLocation];
//    [self.mapView centerAtMyLocationWithScaleLevel:15];
//    [self.mapView zoomToPlace:@"New York" animated:YES];

- (void)viewDidUnload
{
    [self setMapView:nil];

    [self setRoutingPanel:nil];
    [self setFindPlacePanel:nil];
    [self setCloudDataPanel:nil];
    [self setGeolocationPanel:nil];
    [self setGraphicsEditPanel:nil];

    [self setRouteStartLabel:nil];
    [self setRouteEndLabel:nil];
    [self setFunctionToolBar:nil];
    [self setEditGraphicsToolbar:nil];
    [self setUndoEditGraphicsButton:nil];
    [self setRedoEditGraphicsButton:nil];
    [self setRouteStartButton:nil];
    [self setRouteEndButton:nil];
	[self setFindPlacesSearchBar:nil];
	[self setBasemapsPicker:nil];
    [self setFindButton:nil];

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
    [self setShowUIButton:nil];
	[self setSaveEditsGraphicsButton:nil];
	[self setFunctionSegControl:nil];

    [self setGraphicsCreatePanel:nil];
	[self setMessageBarAlertBackdrop:nil];
	[self setRouteFromTextField:nil];
	[self setRouteToTextField:nil];
	[self setRouteToLeftView:nil];
	[self setRouteFromLeftView:nil];
    [self setDirectionsStartContainerView:nil];
    [self setDirectionsEndContainerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - Initialization Methods
- (void) initApp
{
	// Track the application state
    self.currentState = EQSSampleAppStateBasemaps;
	
	// Initialize our property for tracking the current basemap type.
    self.currentBasemapType = EQSBasemapTypeTopographic;

	// Set up some storage areas for search results.
	self.geocodeResults = [NSMutableOrderedSet orderedSet];
    self.geolocationResults = [NSMutableOrderedSet orderedSet];
}

- (void)prepUI
{
    // Disable Cloud Data for now.
	[self.functionSegControl setEnabled:NO forSegmentAtIndex:3];
	
    // Go through all the various UI component views, hide them and then place them properly
    // in the UI window so that they'll fade in and out properly.
    UIView *aView = nil;
    for (UIView *v in [self allUIViews])
    {
        v.alpha = 0;
        v.hidden = YES;
        CGFloat frameHeight = v.frame.size.height;
        objc_setAssociatedObject(v, @"Height", [NSNumber numberWithFloat:frameHeight], OBJC_ASSOCIATION_RETAIN);
        v.frame = [self getUIFrame:v];
        if (!aView)
        {
            aView = v;
        }
    }
    
    self.routeResultsView.hidden = YES;
    self.routeResultsView.alpha = 0;
    
    self.messageBar.hidden = YES;
    self.messageBar.alpha = 0;

    // Position the Message Bar in at least roughly the right spot.
    if (aView)
    {
        self.messageBar.frame = [self getMessageFrameForMasterFrame:aView];
    }
	
	self.routeFromTextField.leftView = self.routeFromLeftView;
	self.routeFromTextField.leftViewMode = UITextFieldViewModeAlways;
	self.routeToTextField.leftView = self.routeToLeftView;
	self.routeToTextField.leftViewMode = UITextFieldViewModeAlways;

    self.findMeButton.layer.cornerRadius = 5;
	
    self.showUIButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.showUIButton.layer.borderWidth = 2;
    self.showUIButton.layer.cornerRadius = 5;
}

- (void)initUI
{
	// Set up the map UI a little.
    [self.mapView enableWrapAround];
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    
    self.mapView.callout.leaderPositionFlags = AGSCalloutLeaderPositionBottom |
	AGSCalloutLeaderPositionLeft |
	AGSCalloutLeaderPositionRight;

	[self initBasemapPicker];
    
    [self initFunctionPicker];
    
    // And show the UI by default. Note, at present the UI is always visible.
    self.uiControlsVisible = YES;
    
    [self registerForUINotifications];
}

- (void)registerForUINotifications
{
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
	
	[self.mapView.routeDisplayHelper registerHandler:self
										  forDirEdit:@selector(routeEditRequested:)
										   clearDirs:@selector(routeDisplayCleared:)
										  andDirStep:@selector(routeNavigationStepSelected:)];
}

#pragma mark - GeoServices Registration
- (void)registerForGeoServicesNotifications
{
	// Let me know when the Geoservices object finds an address for a point.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(gotAddressFromPoint:)
												 name:kEQSGeoServicesNotification_AddressFromPoint_OK
											   object:self.mapView.geoServices];
    // Or not...
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFailToGetAddressFromPoint:)
												 name:kEQSGeoServicesNotification_AddressFromPoint_Error
											   object:self.mapView.geoServices];
    
    // And I also want to know when it found directions we asked for.
	[self.mapView.geoServices registerHandler:self
					 forFindDirectionsSuccess:@selector(didSolveRouteOK:)
								   andFailure:@selector(didFailToSolveRoute:)];
    
    // And let me know when it finds points for an address.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotFindPlacesResults:)
                                                 name:kEQSGeoServicesNotification_PointsFromAddress_OK
                                               object:self.mapView.geoServices];
    // Or not...
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToFindPlaces:)
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



#pragma mark - AGSMapView Events

- (BOOL) mapView:(AGSMapView *)mapView shouldShowCalloutForGraphic:(AGSGraphic *)graphic
{
    switch (self.currentState) {
        case EQSSampleAppStateGraphics:
        case EQSSampleAppStateGraphics_Editing_Point:
        case EQSSampleAppStateGraphics_Editing_Line:
        case EQSSampleAppStateGraphics_Editing_Polygon:
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
                AGSGraphic *editGraphic = [self.mapView editGraphicFromMapViewDidClickAtPoint:graphics];
                EQSSampleAppState newState = EQSSampleAppStateGraphics;
                if (editGraphic)
    {
                    AGSGeometryType geomType = AGSGeometryTypeForGeometry(editGraphic.geometry);
                    switch (geomType) {
                        case AGSGeometryTypePoint:
                        case AGSGeometryTypeMultipoint:
                            newState = EQSSampleAppStateGraphics_Editing_Point;
                            break;
                        case AGSGeometryTypePolyline:
                            newState = EQSSampleAppStateGraphics_Editing_Line;
                            break;
                        case AGSGeometryTypePolygon:
                        case AGSGeometryTypeEnvelope:
                            newState = EQSSampleAppStateGraphics_Editing_Polygon;
                            break;
                        default:
                            NSLog(@"Unrecognized geometry type to edit! %d", geomType);
                            break;
                    }
                    self.currentState = newState;
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
                [self.mapView.callout showCalloutAtPoint:mapPoint forGraphic:g animated:YES];
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


#pragma mark - Progress UI
- (void) showProgressWithMessage:(NSString *)message
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.mapView animated:YES];
	hud.labelText = message;
}

- (void) hideProgress
{
	[MBProgressHUD hideAllHUDsForView:self.mapView animated:YES];
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
    CGSize viewSize = viewToDisplay.frame.size;
    double keyboardHeight = self.keyboardSize.height;
    CGFloat storedHeight = ((NSNumber *)objc_getAssociatedObject(viewToDisplay, @"Height")).doubleValue;

	CGFloat frameOffsetY = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //TODO - make a constant
        CGFloat frameHeight = -1;
        if (self.currentState == EQSSampleAppStateFindPlace)
        {
            if (keyboardHeight == 0)
            {
				frameHeight = storedHeight;
				// Keyboard is hidden. Let's show what we need to.
				if (self.geocodeResults.count == 0)
				{
					frameOffsetY = 70;
				}
            }
            else
            {
                // We want to hide the scrollview.
                frameHeight = 44;
            }
        }
        else if (self.currentState == EQSSampleAppStateGraphics_Editing_Point ||
                 self.currentState == EQSSampleAppStateGraphics_Editing_Line ||
                 self.currentState == EQSSampleAppStateGraphics_Editing_Polygon)
        {
            frameHeight = storedHeight;
        }
        else if (self.currentState == EQSSampleAppStateGraphics)
        {
            frameHeight = storedHeight;
        }
        else if (self.currentState == EQSSampleAppStateDirections_Navigating)
        {
            frameHeight = storedHeight;
        }
        if (frameHeight != -1)
        {
            viewSize = CGSizeMake(viewSize.width, frameHeight);
        }
    }

    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        // Why? WHY!!!? But OK. If I have to.
        keyboardHeight = self.keyboardSize.width;
    }
	//    NSLog(@"Screen Height: %f, view Height: %f, keyboard Height: %f", screenFrame.size.height, viewFrame.size.height, keyboardHeight);
    CGPoint origin = CGPointMake(screenFrame.origin.x, screenFrame.size.height - viewSize.height - keyboardHeight);
	//    NSLog(@"Screen: %@", NSStringFromCGRect(screenFrame));
    CGRect newFrame = CGRectMake(origin.x, origin.y + frameOffsetY, viewSize.width, viewSize.height);
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
    
    return messageFrame;
}

#pragma mark - Application State

- (EQSSampleAppState)currentState
{
    return _currentState;
}

- (void) setCurrentState:(EQSSampleAppState)currentState
{
	@try
	{
		if (_currentState == EQSSampleAppStateGraphics_Editing_Point ||
            _currentState == EQSSampleAppStateGraphics_Editing_Line ||
            _currentState == EQSSampleAppStateGraphics_Editing_Polygon)
		{
			if (self.mapView.getUndoManagerForGraphicsEdits.canUndo ||
				self.mapView.getUndoManagerForGraphicsEdits.canRedo)
			{
				UIAlertView *editAlert = [[UIAlertView alloc] initWithTitle:@"Unsaved Edits"
																	message:@"Are you sure you want to leave Graphics mode? Any unsaved edits will be lost!"
																   delegate:self
														  cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
				NSNumber *n = [NSNumber numberWithInt:currentState];
				objc_setAssociatedObject(editAlert, @"GraphicsEditExitWarning", n, OBJC_ASSOCIATION_RETAIN);
				[editAlert show];
				return;
			}
		}
		_currentState = currentState;
		
		switch (_currentState)
		{
			case EQSSampleAppStateDirections:
			case EQSSampleAppStateDirections_GettingRoute:
			case EQSSampleAppStateDirections_Navigating:
				self.routeStartButton.selected = NO;
				self.routeEndButton.selected = NO;
				[self setStartAndEndText];
                [self setStartAndEndDisplayStyle];
				break;

			case EQSSampleAppStateDirections_WaitingForRouteStart:
				self.routeStartButton.selected = YES;
				self.routeEndButton.selected = NO;
				[self setStartAndEndText];
                [self setStartAndEndDisplayStyle];
				break;
			case EQSSampleAppStateDirections_WaitingForRouteEnd:
				self.routeEndButton.selected = YES;
				self.routeStartButton.selected = NO;
				[self setStartAndEndText];
                [self setStartAndEndDisplayStyle];
				break;
				
			case EQSSampleAppStateGraphics_Editing_Point:
            case EQSSampleAppStateGraphics_Editing_Line:
            case EQSSampleAppStateGraphics_Editing_Polygon:
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
        
        self.mapView.callout.hidden = YES;
		
		[self updateUIDisplayState];
		
		self.codeViewer.viewController.currentAppState = _currentState;
	}
	@finally {
		[self ensureUIMatchesCurrentState];
	}
}

- (void) ensureUIMatchesCurrentState
{
	NSInteger newSegIndex = -1;
	switch (self.currentState) {
		case EQSSampleAppStateBasemaps:
		case EQSSampleAppStateBasemaps_Loading:
			newSegIndex = 0;
			break;
		case EQSSampleAppStateGeolocation:
		case EQSSampleAppStateGeolocation_Locating:
		case EQSSampleAppStateGeolocation_GettingAddress:
			newSegIndex = 1;
			break;
		case EQSSampleAppStateGraphics:
		case EQSSampleAppStateGraphics_Editing_Point:
        case EQSSampleAppStateGraphics_Editing_Line:
        case EQSSampleAppStateGraphics_Editing_Polygon:
			newSegIndex = 2;
			break;
		case EQSSampleAppStateCloudData:
			newSegIndex = 3;
			break;
		case EQSSampleAppStateFindPlace:
		case EQSSampleAppStateFindPlace_Finding:
		case EQSSAmpleAppStateFindPlace_GettingAddress:
			newSegIndex = 4;
			break;
		case EQSSampleAppStateDirections:
		case EQSSampleAppStateDirections_WaitingForRouteStart:
		case EQSSampleAppStateDirections_WaitingForRouteEnd:
		case EQSSampleAppStateDirections_GettingRoute:
		case EQSSampleAppStateDirections_Navigating:
			newSegIndex = 5;
			
//		default:
//			NSLog(@"Could not determine SegmentControl Index from App State %d", self.currentState);
//			return;
	}
	if (newSegIndex != self.functionSegControl.selectedSegmentIndex)
	{
		self.functionSegControl.selectedSegmentIndex = newSegIndex;
	}
}

#pragma mark - UI Function Selection

- (void) setUserMessage:(NSString *)userMessage
{
    // Only animate and change the message if necessary. We don't want to just flicker
    // the display unnecessarily.
    BOOL changingMessage = ![userMessage isEqualToString:_userMessage];
    
	_userMessage = userMessage;
    
    if (changingMessage)
    {
        if (!self.messageBar.hidden)
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.messageBarLabel.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 self.messageBarLabel.text = _userMessage;
                                 [UIView animateWithDuration:0.4
                                                  animations:^{
                                                      self.messageBarLabel.alpha = 1;
                                                  }];
                             }];
        }
        else
        {
            // Initially, the messageBar is hidden. "Hidden" is not an animatable property of
            // UIView, so to avoid the mmessageBar appearing before the new text is animated
            // in (and on load, seeing whatever's set for the Label text in Interface Builder),
            // we'll update the text immediately. No sense in animating something that's not visible.
            self.messageBarLabel.text = _userMessage;
        }
    }
}

- (void) setCurrentState:(EQSSampleAppState) appState withUserAlertMessage:(NSString *)userMessage
{
	self.currentState = appState;
	UIAlertView *errView = [[UIAlertView alloc] initWithTitle:@"Oops!"
													  message:userMessage
													 delegate:nil
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
	[errView show];
}

- (void) clearAlertState
{
	if (self.messageState == EQSSampleAppMessageStateAlert)
	{
		self.messageState = EQSSampleAppMessageStateNormal;
		self.currentState = self.currentState;
	}
}

- (void) setMessageState:(EQSSampleAppMessageState)messageState
{
    BOOL unHiding = (/*_messageState == EQSSampleAppMessageStateHidden &&*/
                     messageState != EQSSampleAppMessageStateHidden);
    BOOL hiding = (/*_messageState != EQSSampleAppMessageStateHidden &&*/
                   messageState == EQSSampleAppMessageStateHidden);

	_messageState = messageState;
	UIColor *bgCol = nil;
	UIColor *fgCol = nil;
	
	self.messageBarAlertBackdrop.hidden = YES;
	
	switch (_messageState)
	{
		case EQSSampleAppMessageStateHighlight:
			bgCol = [UIColor greenColor];
			fgCol = [UIColor blackColor];
			break;
			
		case EQSSampleAppMessageStateAlert:
			bgCol = [UIColor redColor];
			fgCol = [UIColor blackColor];
			self.messageBarAlertBackdrop.hidden = NO;
			break;
            
		default:
			bgCol = [UIColor blackColor];
			fgCol = [UIColor whiteColor];
			break;
	}
	
	self.messageBar.backgroundColor = [bgCol colorWithAlphaComponent:0.93];
	self.messageBarLabel.textColor = fgCol;
    
    if (unHiding)
    {
        self.messageBar.hidden = NO;
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.messageBar.alpha = 1;
                         }];
    }
    else if (hiding)
    {
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.messageBar.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             self.messageBar.hidden = YES;
                         }];
    }
}

- (void) setUserMessageForCurrentFunction
{
	NSString *newMessage = nil;
	EQSSampleAppMessageState newState = EQSSampleAppMessageStateNormal;
	
    switch (self.currentState)
	{
        case EQSSampleAppStateBasemaps:
            newMessage = [NSString stringWithFormat:@"Select Basemap [%@]", [EQSHelper getBasemapName:self.currentBasemapType]];
			break;
		case EQSSampleAppStateBasemaps_Loading:
			newMessage = @"Loading…";
        case EQSSampleAppStateGeolocation:
            newMessage = @"Find your location";
			break;
		case EQSSampleAppStateGeolocation_Locating:
			newMessage = @"Finding your geolocation…";
			break;
		case EQSSampleAppStateGeolocation_GettingAddress:
			newMessage = @"Getting your address…";
			break;
        case EQSSampleAppStateGraphics:
            newMessage = @"Edit graphic, or create a graphic below";
			break;
        case EQSSampleAppStateGraphics_Editing_Point:
			if ([self.mapView getUndoManagerForGraphicsEdits].canUndo)
			{
				newMessage = @"Tap the check mark to save";
			}
			else
			{
				newMessage = @"Tap the map to place a point";
			}
			break;
        case EQSSampleAppStateGraphics_Editing_Line:
			if ([self.mapView getUndoManagerForGraphicsEdits].canUndo)
			{
				newMessage = @"Tap the check mark to save";
			}
			else
			{
				newMessage = @"Tap the map to edit a line";
			}
			break;
        case EQSSampleAppStateGraphics_Editing_Polygon:
			if ([self.mapView getUndoManagerForGraphicsEdits].canUndo)
			{
				newMessage = @"Tap the check mark to save";
			}
			else
			{
				newMessage = @"Tap the map to edit a polygon";
			}
			break;
        case EQSSampleAppStateFindPlace:
            newMessage = @"Enter search text or tap the map";
			break;
		case EQSSampleAppStateFindPlace_Finding:
			newMessage = @"Searching for results…";
			newState = EQSSampleAppMessageStateHighlight;
			break;
		case EQSSAmpleAppStateFindPlace_GettingAddress:
			newMessage = @"Looking up address…";
			newState = EQSSampleAppMessageStateHighlight;
			break;
        case EQSSampleAppStateDirections:
            newMessage = @"Tap below to calculate driving directions";
			break;
        case EQSSampleAppStateDirections_WaitingForRouteStart:
            newMessage = @"Tap the start point of the route";
			newState = EQSSampleAppMessageStateHighlight;
			break;
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
            newMessage = @"Tap the end point of the route";
			newState = EQSSampleAppMessageStateHighlight;
			break;
		case EQSSampleAppStateDirections_GettingRoute:
			newMessage = @"Calculating directions…";
			newState = EQSSampleAppMessageStateHighlight;
			break;
		case EQSSampleAppStateDirections_Navigating:
			newMessage =  @"Navigate the route, step-by-step";
			break;
        case EQSSampleAppStateCloudData:
            newMessage =  @"Access World City features in the cloud";
			break;
            
//        default:
//            NSLog(@"Can't get message for unknown app state %d", self.currentState);
//            newMessage =  @"Magic unknown functionality! Well done!";
//			newState = EQSSampleAppMessageStateAlert;
//            break;
    }
	
	self.userMessage = newMessage;
	self.messageState = newState;
}

- (void)initFunctionPicker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.functionSelectedImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"basemaps-white.png"],
                                       [UIImage imageNamed:@"location-white.png"],
                                       [UIImage imageNamed:@"graphics-white.png"],
                                       [UIImage imageNamed:@"cloud-white.png"],
                                       [UIImage imageNamed:@"find-white.png"],
                                       [UIImage imageNamed:@"directions-white.png"],
                                       nil];
        
        NSMutableArray *images = [NSMutableArray array];
        for (NSInteger i = 0; i < self.functionSegControl.numberOfSegments; i++)
        {
            [images addObject:[self.functionSegControl imageForSegmentAtIndex:i]];
        }
        
        self.functionDefaultImages = images;
        
        [self setFunctionPickerImages];
    }
}

- (IBAction)functionChanged:(id)sender {
    UISegmentedControl *seg = sender;
	EQSSampleAppState newState;
    switch (seg.selectedSegmentIndex) {
        case 0:
            newState = EQSSampleAppStateBasemaps;
            break;
        case 1:
            newState = EQSSampleAppStateGeolocation;
            break;
        case 2:
            newState = EQSSampleAppStateGraphics;
            break;
        case 3:
            newState = EQSSampleAppStateCloudData;
            break;
        case 4:
            newState = EQSSampleAppStateFindPlace;
            break;
        case 5:
            if (self.mapView.routeDisplayHelper.currentRouteResult)
            {
                newState = EQSSampleAppStateDirections_Navigating;
            }
            else
            {
                newState = EQSSampleAppStateDirections;
            }
            break;
        default:
            NSLog(@"Set state to unknown seg index %d", seg.selectedSegmentIndex);
            return;
    }
    
    [self setFunctionPickerImages];
	
	self.currentState = newState;
}

- (void)setFunctionPickerImages
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        UISegmentedControl *seg = self.functionSegControl;
        // Set the old images
        for (NSInteger i = 0; i < seg.numberOfSegments; i++)
        {
            NSArray *srcArray = self.functionDefaultImages;
            if (i == seg.selectedSegmentIndex)
            {
                srcArray = self.functionSelectedImages;
            }
            [seg setImage:[srcArray objectAtIndex:i] forSegmentAtIndex:i];
        }
    }
}

- (NSMutableArray *)allUIViews
{
    NSMutableArray *uiViews = [NSMutableArray arrayWithObjects:self.routingPanel,
                               self.basemapsPicker,
                               self.geolocationPanel,
                               self.findPlacePanel,
                               self.graphicsEditPanel,
                               self.graphicsCreatePanel,
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
    
    switch (self.currentState)
	{
        case EQSSampleAppStateBasemaps:
		case EQSSampleAppStateBasemaps_Loading:
            viewToShow = self.basemapsPicker;
            break;
        case EQSSampleAppStateDirections:
        case EQSSampleAppStateDirections_WaitingForRouteStart:
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
		case EQSSampleAppStateDirections_GettingRoute:
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
		case EQSSampleAppStateFindPlace_Finding:
		case EQSSAmpleAppStateFindPlace_GettingAddress:
            viewToShow = self.findPlacePanel;
            break;
        case EQSSampleAppStateCloudData:
            viewToShow = self.cloudDataPanel;
            break;
        case EQSSampleAppStateGeolocation:
		case EQSSampleAppStateGeolocation_Locating:
		case EQSSampleAppStateGeolocation_GettingAddress:
            viewToShow = self.geolocationPanel;
            break;
        case EQSSampleAppStateGraphics:
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                viewToShow =self.graphicsEditPanel;
            }
            else
            {
                viewToShow = self.graphicsCreatePanel;
            }
            break;
        case EQSSampleAppStateGraphics_Editing_Point:
        case EQSSampleAppStateGraphics_Editing_Line:
        case EQSSampleAppStateGraphics_Editing_Polygon:
            viewToShow = self.graphicsEditPanel;
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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.currentState == EQSSampleAppStateDirections_Navigating)
    {
        [self.routeResultsView.viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                                               duration:duration];
    }

    BOOL hideStatusBar = YES;
	
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ||
        (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && ![self isFullScreen]))
    {
		hideStatusBar = NO;
    }

	[UIView animateWithDuration:duration
					 animations:^{
						 [[UIApplication sharedApplication] setStatusBarHidden:hideStatusBar
																 withAnimation:UIStatusBarAnimationSlide];
						 self.view.frame = [UIScreen mainScreen].applicationFrame;
						 [self positionMessageBar];
					 }];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.currentState == EQSSampleAppStateDirections_Navigating)
    {
        [self.routeResultsView.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    [self.codeViewer.viewController refreshCodeSnippetViewerPosition];
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

- (void) positionMessageBar
{
	UIView *currentView = [self getViewToShow];
	self.messageBar.frame = [self getMessageFrameForMasterFrame:currentView];
}

- (void)updateUIDisplayStateOverDuration:(NSTimeInterval)animationDuration forOrientation:(UIInterfaceOrientation)orientation
{
    UIView *viewToShow = [self getViewToShow];
    NSArray *viewsToHide = [self getViewsToHide];
    
    // If the view is already visible, then we don't need to update...
    BOOL needToChange = YES; // viewToShow.hidden == NO;
    
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
        
        viewToShow.hidden = NO;
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

                             viewToShow.alpha = 1;
                             viewToAnimateOut.alpha = 0;
                             
                             viewToShow.frame = [self getUIFrame:viewToShow forOrientation:orientation];

                             [self positionMessageBar];
//                             self.messageBar.frame = [self getMessageFrameForMasterFrame:viewToShow];
                             [self setUserMessageForCurrentFunction];
                         }
                         completion:^(BOOL finished) {
                             viewToAnimateOut.hidden = YES;
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            if (self.currentState == EQSSampleAppStateDirections ||
				self.currentState == EQSSampleAppStateDirections_GettingRoute ||
                self.currentState == EQSSampleAppStateDirections_WaitingForRouteStart ||
                self.currentState == EQSSampleAppStateDirections_WaitingForRouteEnd ||
				self.currentState == EQSSampleAppStateDirections_Navigating)
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

- (void) setButtonStatesForUndoManager:(NSUndoManager *)um
{
    if (um)
    {
        self.undoEditGraphicsButton.enabled = um.canUndo;
        self.redoEditGraphicsButton.enabled = um.canRedo;
		self.saveEditsGraphicsButton.enabled = um.canUndo;
    }
}

- (void) setZoomToGraphicButtonState
{
    AGSGeometry *editGeom = [self.mapView getCurrentEditGeometry];
    self.zoomToGraphicButton.enabled = !editGeom.isEmpty;
}

- (void) setUndoRedoButtonStates
{
    [self setButtonStatesForUndoManager:[self.mapView getUndoManagerForGraphicsEdits]];
}

- (void) editUndoRedoChanged:(NSNotification *)notification
{
    NSUndoManager *um = notification.object;
    [self setButtonStatesForUndoManager:um];
    [self setZoomToGraphicButtonState];
	[self setUserMessageForCurrentFunction];
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

- (void)basemapDidChange:(NSNotification *)notification
{
    AGSPortalItem *pi = [notification basemapPortalItem];
	self.currentPortalItem = pi;
    EQSBasemapType basemapType = [notification basemapType];
    self.currentBasemapType = basemapType;
	
    self.basemapsPicker.currentPortalItemID = pi.itemId;
    if (self.currentState == EQSSampleAppStateBasemaps)
    {
        [self setUserMessageForCurrentFunction];
    }
}

- (void)basemapSelected:(EQSBasemapType)basemapType
{
	self.currentBasemapType = basemapType;
	self.currentPortalItem = self.basemapsPicker.currentPortalItem;
	[self.mapView setBasemap:basemapType];
}

- (void)setCurrentBasemapType:(EQSBasemapType)currentBasemapType
{
    _currentBasemapType = currentBasemapType;
	
	NSString *portalItemID = [EQSHelper getBasemapWebMap:_currentBasemapType].portalItem.itemId;
	self.basemapsPicker.currentPortalItemID = portalItemID;
}

- (EQSBasemapType)currentBasemapType
{
    return _currentBasemapType;
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
    else if ([segue.identifier isEqualToString:@"ShowCode"])
    {
        EQSCodeViewController *cvc = segue.destinationViewController;
        cvc.delegate = self;
        cvc.currentAppState = self.currentState;
    }
}

- (void) codeviewWantsToBeDismissed:(EQSCodeViewController *)codeviewController
{
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - Graphics

- (IBAction)createNewPtGraphic:(id)sender {
    [self.mapView createAndEditNewPoint];
    self.currentState = EQSSampleAppStateGraphics_Editing_Point;
}

- (IBAction)createNewLnGraphic:(id)sender {
    [self.mapView createAndEditNewLine];
    self.currentState = EQSSampleAppStateGraphics_Editing_Line;
}

- (IBAction)createNewPgGraphic:(id)sender {
    [self.mapView createAndEditNewPolygon];
    self.currentState = EQSSampleAppStateGraphics_Editing_Polygon;
}

- (IBAction)saveGraphicsEdit:(id)sender {
    [self.mapView saveGraphicEdit];
    self.currentState = EQSSampleAppStateGraphics;
}

- (IBAction)cancelGraphicsEdit:(id)sender {
    [self.mapView cancelGraphicEdit];
    self.currentState = EQSSampleAppStateGraphics;
}

- (IBAction)undoGraphicsEdit:(id)sender {
    [self.mapView undoGraphicEdit];
}

- (IBAction)redoGraphicsEdit:(id)sender {
    [self.mapView redoGraphicEdit];
}

- (IBAction)zoomToEditGeometry:(id)sender {
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
- (void) gotAddressFromPoint:(NSNotification *)notification
{
	[self hideProgress];

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
                [g setAttributeWithString:@"ReverseGeocoded" forKey:@"Source"];
                for (NSString *key in candidate.attributes.allKeys)
                {
                    [g setAttribute:[candidate.attributes objectForKey:key] forKey:key];
                }
                
                EQSSearchResultPanelViewController *cvc =
                [[EQSSearchResultPanelViewController alloc] initWithAddressCandidate:candidate
                                                                             OfType:EQSSearchResultTypeReverseGeocode];
                cvc.searchResultViewDelegate = self;
                cvc.graphic = g;
                [cvc addToScrollView:self.findPlacesScrollView];
                [self.geocodeResults addObject:cvc];

                [self.mapView.callout showCalloutAtPoint:p forGraphic:g animated:YES];
			}
            else if ([source isEqualToString:kEQSGetAddressReason_AddressForGeolocation])
            {
                // Clear any old Geolocation results
                [self.mapView removeGraphicsByAttribute:@"Source" withValue:@"Geolocation"];
                
                
                AGSPoint *geoLocation = [notification findAddressSearchPoint];
                AGSGraphic *g = [self.mapView addPoint:geoLocation withSymbol:self.mapView.defaultSymbols.geolocation];
                [g setAttributeWithString:@"Geolocation" forKey:@"Source"];
                for (NSString *key in candidate.attributes.allKeys)
                {
                    [g setAttribute:[candidate.attributes objectForKey:key] forKey:key];
                }

                EQSSearchResultPanelViewController *cvc =
                [[EQSSearchResultPanelViewController alloc] initWithAddressCandidate:candidate
                                                                             OfType:EQSSearchResultTypeGeolocation];
                cvc.searchResultViewDelegate = self;
                cvc.graphic = g;
                [cvc addToScrollView:self.findMeScrollView];
                [self.geolocationResults addObject:cvc];

                self.myLocationAddressLabel.text = address;

                [self.mapView.callout showCalloutAtPoint:geoLocation forGraphic:g animated:YES];
            }
			
			[self updateUIDisplayState];
		}
	}
}

- (void) didFailToGetAddressFromPoint:(NSNotification *)notification
{
	[self hideProgress];

	NSError *error = [notification geoServicesError];
	NSLog(@"Failed to get address for location: %@", error);

    AGSPoint *failedPoint = [notification findAddressSearchPoint];
	[self setCurrentState:self.currentState
	 withUserAlertMessage:[NSString stringWithFormat:@"No address found at %.4f,%.4f", failedPoint.latitude, failedPoint.longitude]];
	
	NSOperation *op = [notification geoServicesOperation];
	if (op)
	{
		NSString *source = objc_getAssociatedObject(op, kEQSGetAddressReasonKey);
		if ([source isEqualToString:kEQSGetAddressReason_RouteStart])
		{
			[self.mapView.routeDisplayHelper setStartPoint:nil];
		} else if ([source isEqualToString:kEQSGetAddressReason_RouteEnd])
		{
			[self.mapView.routeDisplayHelper setEndPoint:nil];
		}
	}
}



#pragma mark - Geolocation
- (IBAction)findMe:(id)sender
{
	// Fire off a request to get the current location.
	[self.mapView centerAtMyLocation];
}

- (void) didGeolocate:(NSNotification *)notification
{
    CLLocation *location = [notification geolocationResult];
    
    if (location)
    {
		// Got the current location. Let's update the UI and request an address for it.
        self.myLocationAddressLabel.text = location.description;
        AGSPoint *locPt = [AGSPoint pointFromLat:location.coordinate.latitude lon:location.coordinate.longitude];
        NSOperation *op = [self.mapView.geoServices findAddressFromPoint:locPt];
		
		// Tag the operation so that gotAddressFromPoint knows this related to a geolocation request
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
	// User tapped on the map
	NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
	// Tag the operation so that gotAddressFromPoint knows this related to a reverse geoode request
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReason_ReverseGeocodeForPoint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




#pragma mark - Get Directions UI
- (IBAction)toFromTapped:(id)sender {
    BOOL selected = ((UIButton *)sender).selected;
    [self setToFromButton:sender selectedState:!selected];
}

- (void)setToFromButton:(UIButton *)bi selectedState:(BOOL)selected
{
    // Clear the other button regardless of the new state for this one.
    UIButton *otherBi = (bi == self.routeStartButton)?self.routeEndButton:self.routeStartButton;
    otherBi.selected = NO;
    
    // Set the new state for this one, and set our app state too.
    NSLog(@"Selected: %@", selected?@"YES":@"NO");
    bi.selected = selected;
    if (selected)
    {
        self.currentState = (bi == self.routeStartButton)?EQSSampleAppStateDirections_WaitingForRouteStart:EQSSampleAppStateDirections_WaitingForRouteEnd;
    }
    else
    {
        self.currentState = EQSSampleAppStateDirections;
    }
}

#pragma mark - Get Directions Map Interactions
- (void)didTapStartPoint:(AGSPoint *)mapPoint
{
	// Drop the point on the map.
	[self.mapView.routeDisplayHelper setStartPoint:mapPoint];
	
	// Fire off a reverse geocode to get the address of the start point
	// See gotAddressFromPoint for more details
	self.routeFromTextField.text = @"";
//	self.routeFromTextField.placeholder = [NSString stringWithFormat:@"Getting address for %.2f,%.2f",
//										   mapPoint.latitude,
//										   mapPoint.longitude];
	[self showProgressWithMessage:@"Finding address…"];
    NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
	// Tag the operation so that gotAddressFromPoint knows this related to a directions start point
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReason_RouteStart, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTapEndPoint:(AGSPoint *)mapPoint
{
	// Drop the point on the map.
	[self.mapView.routeDisplayHelper setEndPoint:mapPoint];
	
	// Fire off a reverse geocode to get the address of the end point
	// See gotAddressFromPoint for more details
	self.routeToTextField.text = @"";
//	self.routeToTextField.placeholder = [NSString stringWithFormat:@"Getting address for %.2f,%.2f",
//										 mapPoint.latitude,
//										 mapPoint.longitude];
	[self showProgressWithMessage:@"Finding address…"];
    NSOperation *op = [self.mapView.geoServices findAddressFromPoint:mapPoint];
	// Tag the operation so that gotAddressFromPoint knows this related to a directions start point
    objc_setAssociatedObject(op, kEQSGetAddressReasonKey, kEQSGetAddressReason_RouteEnd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

#pragma mark - Prepare Directions from Reverse Geocode Results
- (void) setRouteStartPoint:(AGSPoint *)routeStartPoint
{
    _routeStartPoint = routeStartPoint;
	
	// Show this on the map.
	[self.mapView.routeDisplayHelper setStartPoint:_routeStartPoint];
    
	// And either solve the route, or prompt for the end point
	if (_routeStartPoint)
    {
		self.currentState = EQSSampleAppStateDirections;
        if (![self doRouteIfPossible])
		{
			self.currentState = EQSSampleAppStateDirections_WaitingForRouteEnd;
		}
    }
}

- (void) setRouteEndPoint:(AGSPoint *)routeEndPoint
{
    _routeEndPoint = routeEndPoint;
	
	// Show this on the map
	[self.mapView.routeDisplayHelper setEndPoint:_routeEndPoint];
    
	// And either solve the route, or prompt for the start point
	if (_routeEndPoint)
    {
		self.currentState = EQSSampleAppStateDirections;
        if (![self doRouteIfPossible])
		{
			self.currentState = EQSSampleAppStateDirections_WaitingForRouteStart;
		}
	}
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

#pragma mark - Request Directions When Ready
- (BOOL) doRouteIfPossible
{
    if (self.routeStartPoint &&
        self.routeEndPoint)
    {
        NSLog(@"Start and end points set... %@ %@", self.routeStartAddress, self.routeEndAddress);
		[self showProgressWithMessage:@"Calculating Directions…"];
        [self.mapView.geoServices findDirectionsFrom:self.routeStartPoint named:self.routeStartAddress
                                                  to:self.routeEndPoint named:self.routeEndAddress];
		self.currentState = EQSSampleAppStateDirections_GettingRoute;
        return YES;
    }
    return NO;
}

- (void) didSolveRouteOK:(NSNotification *)notification
{
    NSLog(@"Entered didSolveRouteOK");

	[self hideProgress];
	
	AGSRouteTaskResult *results = [notification routeTaskResults];
    NSLog(@"Got UserInfo");
	if (results)
	{
        // Store the route result for ourselves.

        // Tell our RouteDisplayHelper about the object we've created in our NIB for the table view.
        self.mapView.routeDisplayHelper.routeResultsViewController = self.routeResultsView.viewController;
		[self.mapView.routeDisplayHelper showRouteResult:results];
        
        self.currentState = EQSSampleAppStateDirections_Navigating;
	}
}

- (void) didFailToSolveRoute:(NSNotification *)notification
{
	[self hideProgress];
	
	NSError *error = [notification geoServicesError];
	if (error)
	{
		NSLog(@"Failed to solve route: %@", error);
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not calculate route"
//														message:[error.userInfo objectForKey:@"NSLocalizedFailureReason"]
//													   delegate:nil
//											  cancelButtonTitle:@"OK"
//											  otherButtonTitles:nil];
//		objc_setAssociatedObject(alert, @"Route Failed", error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//		[alert show];
//		self.currentState = EQSSampleAppStateDirections;
//		self.userMessage = @"Could not solve route!";
//		self.messageState = EQSSampleAppMessageStateAlert;
		[self setCurrentState:EQSSampleAppStateDirections withUserAlertMessage:@"Could not solve route!"];
	}
}

#pragma mark - Directions UI Feedback
- (void) setStartAndEndText
{
	[self setStartText];
	[self setEndText];
}

- (void) setStartAndEndDisplayStyle
{
    CGFloat passiveAlpha = 0.5;
    CGAffineTransform passiveT = CGAffineTransformMakeScale(0.95, 0.95 );
    
    CGFloat startAlpha = 1;
    CGFloat endAlpha = 1;
    
    CGAffineTransform startT = CGAffineTransformIdentity;
    CGAffineTransform endT = CGAffineTransformIdentity;
    
    if (self.currentState == EQSSampleAppStateDirections_WaitingForRouteStart)
    {
        endAlpha = passiveAlpha;
        endT = passiveT;
    }
    else if (self.currentState == EQSSampleAppStateDirections_WaitingForRouteEnd)
    {
        startAlpha = passiveAlpha;
        startT = passiveT;
    }
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         if (self.directionsStartContainerView.alpha != startAlpha)
                         {
                             self.directionsStartContainerView.alpha = startAlpha;
                             self.directionsStartContainerView.transform = startT;
                         }
                         if (self.directionsEndContainerView.alpha != endAlpha)
                         {
                             self.directionsEndContainerView.alpha = endAlpha;
                             self.directionsEndContainerView.transform = endT;
                         }
                     }];
}

- (void) setStartText
{
    NSString *latLongText = nil;
    if (self.routeStartPoint)
    {
        latLongText = [NSString stringWithFormat:@"%.4f,%.4f",
					   self.routeStartPoint.latitude,
					   self.routeStartPoint.longitude];
    }
    NSString *address = self.routeStartAddress;
	if (address)
	{
		self.routeFromTextField.text = address;
	}
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
//        if (self.routeStartButton.selected)
//        {
//            self.routeStartLabel.text = @"Tap start of route on map";
//        }
//        else
//        {
//            self.routeStartLabel.text = @"Tap button";
//        }
		self.routeStartLabel.text = self.routeFromTextField.text = @"";
    }
}

- (void) setEndText
{
    NSString *latLongText = self.routeEndPoint?[NSString stringWithFormat:@"%.4f,%.4f",
												self.routeEndPoint.latitude,
												self.routeEndPoint.longitude]:nil;
    NSString *address = self.routeEndAddress;
	if (address)
	{
		self.routeToTextField.text = address;
	}
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
//        if (self.routeEndButton.selected)
//        {
//            self.routeEndLabel.text = @"Tap end of route on map";
//        }
//        else
//        {
//            self.routeEndLabel.text = @"Tap button";
//        }
		self.routeEndLabel.text = self.routeToTextField.text = @"";
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

- (void) routeNavigationStepSelected:(NSNotification *)notification
{
    self.messageState = EQSSampleAppMessageStateHidden;
}

#pragma mark - Full Screen UI Mode
- (IBAction)resizeUIGoFullScreen:(id)sender
{
    self.showUIButton.hidden = YES;
    self.showUIButton.alpha = 0;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.functionNavBar_iPhone.alpha = 0;
                         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                         self.view.frame = [UIScreen mainScreen].applicationFrame;
                         self.mapView.frame = CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height + self.functionNavBar_iPhone.frame.size.height);
                         self.showUIButton.hidden = NO;
                     }
                     completion:^(BOOL finished) {
                         self.functionNavBar_iPhone.hidden = YES;
                         [UIView animateWithDuration:0.4 animations:^{
                             self.showUIButton.alpha = 1;
                         }];
                     }];
}

- (IBAction)resizeUIExitFullScreen:(id)sender
{
    self.functionNavBar_iPhone.alpha = 0;
    self.functionNavBar_iPhone.hidden = NO;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.showUIButton.alpha = 0;
                         if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
                         {
                             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                         }
                         self.view.frame = [UIScreen mainScreen].applicationFrame;
                         self.mapView.frame = CGRectMake(0, self.functionNavBar_iPhone.frame.size.height,
                                                         self.mapView.frame.size.width,
                                                         self.mapView.frame.size.height - self.functionNavBar_iPhone.frame.size.height);
                         self.functionNavBar_iPhone.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.showUIButton.hidden = YES;
                     }];
}

- (BOOL) isFullScreen
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        // We don't (currently) hide the UI in iPad view.
        return YES;
    }
    else
    {
        return self.functionNavBar_iPhone.hidden;
    }
}


#pragma mark - Find Places
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *searchString = searchBar.text;
    [self findPlaces:searchString];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (IBAction)findPlacesTapped:(id)sender {
    NSString *searchString = self.findPlacesSearchBar.text;
    [self findPlaces:searchString];
}

- (void)findPlaces:(NSString *)searchString
{
	// Hide the keyboard.
	[self.findPlacesSearchBar resignFirstResponder];

	// Find places, using the current view extent as a constraint
	NSLog(@"Searching for: %@", searchString);
    AGSPolygon *v = self.mapView.visibleArea;
    AGSEnvelope *env = v.envelope;
	[self.mapView.geoServices findPlaces:searchString withinEnvelope:env];
}

#pragma mark - Find Places Service Handlers
- (void) gotFindPlacesResults:(NSNotification *)notification
{
    NSOperation *op = [notification geoServicesOperation];
	
    if (op)
    {
        NSArray *candidates = notification.findPlacesCandidatesSortedByScore;
        if (candidates.count > 0)
        {
            // First, let's remove all the old items from the UI (if any)
            NSMutableArray *geocodeResultsToDiscard = [NSMutableArray array];
            for (EQSSearchResultPanelViewController *gcvc in self.geocodeResults)
            {
                if (gcvc.resultType == EQSSearchResultTypeForwardGeocode)
                {
                    [gcvc.graphic.layer removeGraphic:gcvc.graphic];
                    [gcvc removeFromParentScrollView];
                    [geocodeResultsToDiscard addObject:gcvc];
                }
            }
            [self.geocodeResults removeObjectsInArray:geocodeResultsToDiscard];

			// Make sure there are no callouts visible on the map
            self.mapView.callout.hidden = YES;
            
			// Make sure the "No results" text is hidden.
            self.findPlacesNoResultsLabel.hidden = YES;

			// Now, we're only going to show results in the top 20% (rank-wise)
            double maxScore = ((AGSAddressCandidate *)[candidates objectAtIndex:0]).score;
            maxScore = maxScore * 0.9f;
			
			// Only considering the top results, in terms of score relative to top score.
			candidates = [candidates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
			{
				AGSLocatorFindResult *r = evaluatedObject;
				return r.score >= maxScore;
			}]];

			// Go through the results, adding them to the UI and map as appropriate, and zooming the map.
            AGSMutableEnvelope *totalEnv = nil;
            EQSSearchResultPanelViewController *firstResultVC = nil;
            for (AGSLocatorFindResult *r in candidates)
			{
				// Add a graphic to the map for this result.
				AGSGraphic *g = r.graphic;
				// Let's track the graphic in the map.
				[g setAttributeWithString:@"Geocoded" forKey:@"Source"];
                g.symbol = self.mapView.defaultSymbols.findPlace;

                // And now we add it to the map.
                [self.mapView addGraphic:g];
				
				
				// Update/Create the overall envelope containing all results.
				AGSPoint *p = (AGSPoint *)g.geometry;
				if (!totalEnv)
				{
					totalEnv = [AGSMutableEnvelope envelopeWithXmin:p.x-1 ymin:p.y-1
															   xmax:p.x+1 ymax:p.y+1
												   spatialReference:p.spatialReference];
				}
				else
				{
					[totalEnv unionWithPoint:p];
				}
				
				// Now create our custom candidate<>UI component.
				EQSSearchResultPanelViewController *cvc =
				[EQSSearchResultPanelViewController viewControllerWithFindResult:r
                                                                                OfType:EQSSearchResultTypeForwardGeocode];
				// Add it to the Find Places scroll view.
				[cvc addToScrollView:self.findPlacesScrollView];
				
				// Give it a handle onto the graphic we created
				cvc.graphic = g;
				
				// And let us handle interactions with the component
				cvc.searchResultViewDelegate = self;
				
				// Lastly, store a handle onto our result container.
				[self.geocodeResults addObject:cvc];
				
				if (!firstResultVC)
				{
					// We want to remember the first item, so that we can make sure it's visible
					// in the UI when we're done adding candidates.
					firstResultVC = cvc;
				}
            }
			
            if (firstResultVC)
            {
				// We found at least one result. Let's make sure it's visible in the non-map UI.
                [firstResultVC ensureVisibleInParentUIScrollView];
            }
            
			if (candidates.count == 1)
            {
				// We had one result. Zoom to a set zoom level.
                [self.mapView zoomToLevel:16 withCenterPoint:[totalEnv center] animated:YES];
            }
            else if (totalEnv)
            {
				// Multiple results - let's zoom to a containing envelope.
                [totalEnv expandByFactor:1.1];
                [self.mapView zoomToEnvelope:totalEnv animated:YES];
            }
			
			[self updateUIDisplayState];
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

- (void) didFailToFindPlaces:(NSNotification *)notification
{
	NSError *error = [notification geoServicesError];
	NSLog(@"Failed to get candidates for address: %@", error);
}


#pragma mark - Geocode Candidate Interacation Delegate Handler
- (void) searchResultViewController:(EQSSearchResultPanelViewController *)candidateVC
                  DidTapViewType:(EQSSearchResultViewType)viewType
{
	// The user tapped the candidate object. Let's make sure its map point is
	// visible on the map
    AGSPoint *location = candidateVC.resultLocation;
    if (location)
    {
        [self.mapView centerAtPoint:location animated:YES];

        AGSGraphic *g = candidateVC.graphic;
        if (g)
        {
            [self.mapView.callout showCalloutAtPoint:location forGraphic:g animated:YES];
        }
    }
	// And let's scroll the containing view to show the result fully.
    [candidateVC ensureVisibleInParentUIScrollView];
}



#pragma mark - Alert Views
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	@try
	{
		// First check to see if this happened because of a search.
		NSNotification *notification = objc_getAssociatedObject(alertView, @"SearchUserInfo");
		if (notification)
		{
			if (buttonIndex == 1)
			{
				// The user wants to searh again, but this time without a constraint envelope.
				NSString *searchText = [notification findPlacesSearchString];
				[self.mapView.geoServices findPlaces:searchText];
			}
			return;
		}
		
		// Still here? Let's see if this happened because a graphic was being edited
		NSNumber *appState = objc_getAssociatedObject(alertView, @"GraphicsEditExitWarning");
		if (appState)
		{
			if (buttonIndex == 1)
			{
				// User chose to abandon edits.
				[self.mapView cancelGraphicEdit];
				
				// Now there's not an edit, we can change the state
				EQSSampleAppState newAppState = appState.intValue;
				self.currentState = newAppState;
				return;
			}
		}
	}
	@finally
	{
		// Let's remove everything off the alertView so it can be released.
		// If we've coded everything properly, that shouldn't be an issue, but no harm
		// in being careful.
		objc_removeAssociatedObjects(alertView);
	}
}



#pragma mark - Message Bar
- (IBAction)messageBarCloseTapped:(id)sender
{
    NSLog(@"Close the message bar now...");
    [self setUserMessageForCurrentFunction];
}
@end
