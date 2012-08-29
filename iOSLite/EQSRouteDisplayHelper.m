//
//  EQSRouteDisplayHelper.m
//  EsriQuickStartApp
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
#import "EQSDefaultSymbols.h"

#define kEQSRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEQSRouteTaskHelperNotificationLoaded @"EQSRouteTaskHelperLoaded"
#define kEQSRouteTaskHelperNotificationRouteSolved @"EQSRouteTaskHelperRouteSolved"

#define kEQSRouteResultsLayerName @"EQSRouteResults"

@interface EQSRouteDisplayHelper ()
- (id) initForMapView:(AGSMapView *)mapView;
@property (nonatomic, retain) AGSMapView *mapView;
@property (nonatomic, strong) AGSCalloutTemplate *startPointCalloutTemplate;
@property (nonatomic, strong) AGSCalloutTemplate *endPointCalloutTemplate;
@end

@implementation EQSRouteDisplayHelper
@synthesize routeGraphicsLayer = _routeGraphicsLayer;

@synthesize startSymbol = _startSymbol;
@synthesize endSymbol = _stopSymbol;
@synthesize routeSymbol = _routeSymbol;

@synthesize mapView = _mapView;

@synthesize startPointCalloutTemplate = _startPointCalloutTemplate;
@synthesize endPointCalloutTemplate = _endPointCalloutTemplate;

#pragma mark - Public static shortcut
+ (EQSRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView
{
    return [[EQSRouteDisplayHelper alloc] initForMapView:mapView];
}

#pragma mark - Public methods
- (void) showRouteResults:(AGSRouteTaskResult *)routeTaskResults;
{
    NSLog(@"Entered showRouteResults");
	if (routeTaskResults.routeResults.count > 0)
	{
		[self.routeGraphicsLayer removeAllGraphics];
		
        AGSRouteResult *result = [routeTaskResults.routeResults objectAtIndex:0];
        AGSGraphic *routeGraphic = [AGSGraphic graphicWithGeometry:result.directions.mergedGeometry
                                                            symbol:self.routeSymbol
                                                        attributes:nil
                                              infoTemplateDelegate:nil];
        [self.routeGraphicsLayer addGraphic:routeGraphic];
		
        for (AGSStopGraphic *stopGraphic in result.stopGraphics)
        {
            NSLog(@"Route Stop Point: \"%@\"", stopGraphic.name);
            NSLog(@"Stop point attribtues:\n%@", stopGraphic.attributes);
            if (stopGraphic.sequence == 1)//.name isEqualToString:kEQSRoutingStartPointName])
            {
                stopGraphic.symbol = self.startSymbol;
                stopGraphic.infoTemplateDelegate = self.startPointCalloutTemplate;
            }
            else if (stopGraphic.sequence == result.stopGraphics.count)//.name isEqualToString:kEQSRoutingEndPointName])
            {
                stopGraphic.symbol = self.endSymbol;
                stopGraphic.infoTemplateDelegate = self.endPointCalloutTemplate;
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
    self = [self init];
    if (self)
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
        self.startSymbol = mapView.defaultSymbols.routeStart;
        self.endSymbol = mapView.defaultSymbols.routeEnd;
        
		self.routeSymbol = mapView.defaultSymbols.route;
        
        self.startPointCalloutTemplate = [[AGSCalloutTemplate alloc] init];
        self.startPointCalloutTemplate.titleTemplate = @"Start";
        self.startPointCalloutTemplate.detailTemplate = @"Oooh";
        
        self.endPointCalloutTemplate = [[AGSCalloutTemplate alloc] init];
        self.endPointCalloutTemplate.titleTemplate = @"End";
        self.endPointCalloutTemplate.detailTemplate = @"Ahhh";
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