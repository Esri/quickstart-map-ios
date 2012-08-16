//
//  STXRouteDisplayHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "STXRouteDisplayHelper.h"

#import "STXHelper.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Basemaps.h"
#import "AGSGraphicsLayer+GeneralUtilities.h"
#import "STXGeoServices.h"

#define kSTXRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kSTXRouteTaskHelperNotificationLoaded @"STXRouteTaskHelperLoaded"
#define kSTXRouteTaskHelperNotificationRouteSolved @"STXRouteTaskHelperRouteSolved"

#define kSTXGreenPinURL @"http://static.arcgis.com/images/Symbols/Shapes/GreenPin1LargeB.png"
#define kSTXRedPinURL @"http://static.arcgis.com/images/Symbols/Shapes/RedPin1LargeB.png"
#define kSTXPinXOffset 0
#define kSTXPinYOffset 11
#define kSTXPinSize CGSizeMake(28,28)

#define kSTXRouteResultsLayerName @"STXRouteResults"

@interface STXRouteDisplayHelper ()
- (id) initForMapView:(AGSMapView *)mapView;
@property (nonatomic, retain) AGSMapView *mapView;
@end

@implementation STXRouteDisplayHelper
@synthesize routeGraphicsLayer = _routeGraphicsLayer;

@synthesize startSymbol = _startSymbol;
@synthesize endSymbol = _stopSymbol;
@synthesize routeSymbol = _routeSymbol;

@synthesize mapView = _mapView;

#pragma mark - Public static shortcut
+ (STXRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView
{
    return [[STXRouteDisplayHelper alloc] initForMapView:mapView];
}

#pragma mark - Public methods
- (void) showRouteResults:(AGSRouteTaskResult *)routeTaskResults;
{
	if (routeTaskResults.routeResults.count > 0)
	{
		[self.routeGraphicsLayer removeAllGraphics];
		
        AGSRouteResult *result = [routeTaskResults.routeResults objectAtIndex:0];
        AGSGraphic *routeGraphic = result.routeGraphic;
        AGSSimpleLineSymbol *routeSymbol = self.routeSymbol;
        routeGraphic.symbol = routeSymbol;
        
        [self.routeGraphicsLayer addGraphic:routeGraphic];
		
        for (AGSStopGraphic *stopGraphic in result.stopGraphics) {
            NSLog(@"Route Stop Point: \"%@\"", stopGraphic.name);
            if ([stopGraphic.name isEqualToString:kSTXRoutingStartPointName])
            {
                stopGraphic.symbol = self.startSymbol;
            }
            else if ([stopGraphic.name isEqualToString:kSTXRoutingEndPointName])
            {
                stopGraphic.symbol = self.endSymbol;
            }
            [self.routeGraphicsLayer addGraphic:stopGraphic];
        }
        
        [self.routeGraphicsLayer dataChanged];
		
        [self.mapView zoomToGeometry:result.routeGraphic.geometry withPadding:100 animated:YES];
    }
}

- (void) clearRouteDisplay
{
    [self.routeGraphicsLayer removeAllGraphics];
    [self.routeGraphicsLayer dataChanged];
}



#pragma mark - Internal init/dealloc, etc.
- (id) initForMapView:(AGSMapView *)mapView
{
    if ([self init])
    {
		// Create a new Graphics Layer
        self.routeGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
		[mapView addMapLayer:self.routeGraphicsLayer withName:kSTXRouteResultsLayerName];
		
		// We need to make sure we re-add the layer when the basemap changes...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(basemapDidChange:)
                                                     name:kSTXNotification_BasemapDidChange
                                                   object:mapView];

		// Keep a handle onto our AGSMapView
		self.mapView = mapView;

		// Set up the default symbols.
        self.startSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kSTXGreenPinURL]]]];
        pms.xoffset = kSTXPinXOffset;
        pms.yoffset = kSTXPinYOffset;
        pms.size = kSTXPinSize;
        self.startSymbol = pms;

        pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kSTXRedPinURL]]]];
        pms.xoffset = kSTXPinXOffset;
        pms.yoffset = kSTXPinYOffset;
        pms.size = kSTXPinSize;
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
	 [self.mapView addMapLayer:self.routeGraphicsLayer withName:kSTXRouteResultsLayerName];
}

#pragma mark - Basemap Change Notification Handler
- (void) basemapDidChange:(NSNotification *)notification
{
    // The basemap changed, which means we need to re-add the basemap layer
    if (![self.mapView getLayerForName:kSTXRouteResultsLayerName])
    {
		[self addRouteResultsLayer];
    }
}
@end