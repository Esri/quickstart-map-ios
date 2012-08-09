//
//  EDNLitRouteTaskHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNLiteRouteTaskHelper.h"

#import "EDNLiteHelper.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Basemaps.h"
#import "AGSGraphicsLayer+GeneralUtilities.h"

#define kEdnLiteRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEdnLiteRouteTaskHelperNotificationLoaded @"EDNLiteRouteTaskHelperLoaded"
#define kEdnLiteRouteTaskHelperNotificationRouteSolved @"EDNLiteRouteTaskHelperRouteSolved"

#define kEDNLiteRoutingIDAttribute @"RouteGraphicID"
#define kEDNLiteRoutingStartPointName @"Start Point"
#define kEDNLiteRoutingStopPointName @"Stop Point"

#define kEDNLiteGreenPinURL @"http://static.arcgis.com/images/Symbols/Shapes/GreenPin1LargeB.png"
#define kEDNLiteRedPinURL @"http://static.arcgis.com/images/Symbols/Shapes/RedPin1LargeB.png"
#define kEDNLitePinXOffset 0
#define kEDNLitePinYOffset 11
#define kEDNLitePinSize CGSizeMake(28,28)

#define kEDNLiteRouteResultsLayerName @"EDNLiteRouteResults"

@interface EDNLiteRouteTaskHelper ()
@property (nonatomic, retain) AGSMapView *mapView;
@end

@implementation EDNLiteRouteTaskHelper
@synthesize routeGraphicsLayer = _routeGraphicsLayer;

@synthesize startSymbol = _startSymbol;
@synthesize endSymbol = _stopSymbol;
@synthesize routeSymbol = _routeSymbol;

@synthesize mapView = _mapView;

#pragma mark - Init/Dealloc
- (id) initForMapView:(AGSMapView *)mapView
{
    if ([self init])
    {
        self.routeGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
		[mapView addMapLayer:self.routeGraphicsLayer withName:kEDNLiteRouteResultsLayerName];
		
		// We need to make sure we re-add the layer when the basemap changes...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(basemapDidChange:)
                                                     name:kEDNLiteNotification_BasemapDidChange
                                                   object:mapView];

		self.mapView = mapView;

        self.startSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kEDNLiteGreenPinURL]]]];
        pms.xoffset = kEDNLitePinXOffset;
        pms.yoffset = kEDNLitePinYOffset;
        pms.size = kEDNLitePinSize;
        self.startSymbol = pms;

        pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kEDNLiteRedPinURL]]]];
        pms.xoffset = kEDNLitePinXOffset;
        pms.yoffset = kEDNLitePinYOffset;
        pms.size = kEDNLitePinSize;
        self.endSymbol = pms;
        
		self.routeSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7f] width:8.0f];
    }    
    
    return self;
}

- (void) dealloc
{
	self.routeGraphicsLayer = nil;
	self.startSymbol = nil;
	self.endSymbol = nil;
	self.routeSymbol = nil;
	self.mapView = nil;
}

- (void) addRouteResultsLayer
{
	// Add a layer to hold the route results.
	void (^addLayerCode)() = ^void
	{
		[self.mapView addMapLayer:self.routeGraphicsLayer withName:kEDNLiteRouteResultsLayerName];
	};
	
	if (self.mapView.loaded)
	{
		// If the mapView is already loaded, just run this code.
		addLayerCode();
	}
	else
	{
		// Otherwise we queue this block up to be run when self (an AGSMapView) *has* loaded
		// since the behaviour doesn't work before then. This is because the map will not yet
		// be fully initialized for UI interaction until then.
		[EDNLiteHelper queueBlock:addLayerCode untilMapViewLoaded:self.mapView];
	}
}

#pragma mark - Basemap Change Notification Handler
- (void) basemapDidChange:(NSNotification *)notification
{
    // The basemap changed, which means we need to re-add the basemap layer
    if (![self.mapView getLayerForName:kEDNLiteRouteResultsLayerName])
    {
		[self addRouteResultsLayer];
    }
}

#pragma mark - Public static shortcut
+ (EDNLiteRouteTaskHelper *) ednLiteRouteTaskHelperForMapView:(AGSMapView *)mapView
{
    return [[EDNLiteRouteTaskHelper alloc] initForMapView:mapView];
}
@end