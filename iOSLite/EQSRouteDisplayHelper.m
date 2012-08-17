//
//  EQSRouteDisplayHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteDisplayHelper.h"

#import "EQSHelper.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Basemaps.h"
#import "AGSGraphicsLayer+GeneralUtilities.h"
#import "EQSGeoServices.h"

#define kEQSRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEQSRouteTaskHelperNotificationLoaded @"EQSRouteTaskHelperLoaded"
#define kEQSRouteTaskHelperNotificationRouteSolved @"EQSRouteTaskHelperRouteSolved"

#define kEQSGreenPinURL @"http://static.arcgis.com/images/Symbols/Shapes/GreenPin1LargeB.png"
#define kEQSRedPinURL @"http://static.arcgis.com/images/Symbols/Shapes/RedPin1LargeB.png"
#define kEQSPinXOffset 0
#define kEQSPinYOffset 11
#define kEQSPinSize CGSizeMake(28,28)

#define kEQSRouteResultsLayerName @"EQSRouteResults"

@interface EQSRouteDisplayHelper ()
- (id) initForMapView:(AGSMapView *)mapView;
@property (nonatomic, retain) AGSMapView *mapView;
@end

@implementation EQSRouteDisplayHelper
@synthesize routeGraphicsLayer = _routeGraphicsLayer;

@synthesize startSymbol = _startSymbol;
@synthesize endSymbol = _stopSymbol;
@synthesize routeSymbol = _routeSymbol;

@synthesize mapView = _mapView;

#pragma mark - Public static shortcut
+ (EQSRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView
{
    return [[EQSRouteDisplayHelper alloc] initForMapView:mapView];
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
            if ([stopGraphic.name isEqualToString:kEQSRoutingStartPointName])
            {
                stopGraphic.symbol = self.startSymbol;
            }
            else if ([stopGraphic.name isEqualToString:kEQSRoutingEndPointName])
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
		[mapView addMapLayer:self.routeGraphicsLayer withName:kEQSRouteResultsLayerName];
		
		// We need to make sure we re-add the layer when the basemap changes...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(basemapDidChange:)
                                                     name:kEQSNotification_BasemapDidChange
                                                   object:mapView];

		// Keep a handle onto our AGSMapView
		self.mapView = mapView;

		// Set up the default symbols.
        self.startSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kEQSGreenPinURL]]]];
        pms.xoffset = kEQSPinXOffset;
        pms.yoffset = kEQSPinYOffset;
        pms.size = kEQSPinSize;
        self.startSymbol = pms;

        pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kEQSRedPinURL]]]];
        pms.xoffset = kEQSPinXOffset;
        pms.yoffset = kEQSPinYOffset;
        pms.size = kEQSPinSize;
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
	 [self.mapView addMapLayer:self.routeGraphicsLayer withName:kEQSRouteResultsLayerName];
}

#pragma mark - Basemap Change Notification Handler
- (void) basemapDidChange:(NSNotification *)notification
{
    // The basemap changed, which means we need to re-add the basemap layer
    if (![self.mapView getLayerForName:kEQSRouteResultsLayerName])
    {
		[self addRouteResultsLayer];
    }
}
@end