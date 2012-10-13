//
//  EQSRouteDisplayHelper.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteDisplayHelper.h"

#import "EQSHelper_int.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Basemaps.h"
#import "AGSMapView+EQSGraphics.h"
#import "AGSGraphicsLayer+EQSGraphics.h"
#import "EQSGeoServices.h"
#import "EQSDefaultSymbols.h"

#import "EQSRouteResultsViewController.h"

#define kEQSRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEQSRouteTaskHelperNotificationLoaded @"EQSRouteTaskHelperLoaded"
#define kEQSRouteTaskHelperNotificationRouteSolved @"EQSRouteTaskHelperRouteSolved"

#define kEQSRouteResultsLayerName @"EQSRouteResults"

#define kEQSRouteDisplayHelperGraphic_RouteStartPoint @"RouteStartPoint"
#define kEQSRouteDisplayHelperGraphic_RouteEndPoint @"RouteEndPoint"

@interface EQSRouteDisplayHelper () <EQSRouteDisplayViewDelegate>
@property (nonatomic, retain) AGSMapView *mapView;
@property (nonatomic, strong) AGSCalloutTemplate *startPointCalloutTemplate;
@property (nonatomic, strong) AGSCalloutTemplate *endPointCalloutTemplate;

@property (nonatomic, retain, readwrite) AGSRouteResult *currentRouteResult;

@property (atomic, assign) BOOL inSetupStack;
@end

@implementation EQSRouteDisplayHelper
@synthesize routeGraphicsLayer = _routeGraphicsLayer;

@synthesize currentRouteResult = _currentRouteResult;

@synthesize startSymbol = _startSymbol;
@synthesize endSymbol = _stopSymbol;
@synthesize routeSymbol = _routeSymbol;

@synthesize mapView = _mapView;

@synthesize routeResultsViewController = _routeResultsViewController;

@synthesize startPointCalloutTemplate = _startPointCalloutTemplate;
@synthesize endPointCalloutTemplate = _endPointCalloutTemplate;

#pragma mark - Public static shortcut
+ (EQSRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView
{
    return [[EQSRouteDisplayHelper alloc] initForMapView:mapView];
}

#pragma mark - Public methods
- (void) showRouteResult:(AGSRouteTaskResult *)routeTaskResult;
{
    NSLog(@"Entered showRouteResults");
	if (routeTaskResult.routeResults.count > 0)
	{
		[self.routeGraphicsLayer removeAllGraphics];
		
        AGSRouteResult *result = [routeTaskResult.routeResults objectAtIndex:0];
        
        self.currentRouteResult = result;
    }
}

- (void) setCurrentRouteResult:(AGSRouteResult *)currentRouteResult
{
    _currentRouteResult = currentRouteResult;
    
    self.inSetupStack = YES;
    
    @try
    {
        [self setupTabularDisplay:_currentRouteResult];
        
        [self setupMapDisplay:_currentRouteResult];
    }
    @finally
    {
        self.inSetupStack = NO;
    }
}

- (void) setRouteResultsViewController:(EQSRouteResultsViewController *)routeResultsViewController
{
    _routeResultsViewController = routeResultsViewController;
    if (_routeResultsViewController)
    {
        if (_routeResultsViewController.routeDisplayDelegate == nil)
        {
            _routeResultsViewController.routeDisplayDelegate = self;
        }
    }
}

- (void) setupTabularDisplay:(AGSRouteResult *)routeResult
{
    if (self.routeResultsViewController)
    {
        self.routeResultsViewController.routeResult = routeResult;
    }
}

- (void) setupMapDisplay:(AGSRouteResult *)routeResult
{
	// Clear the route display.
	[self.routeGraphicsLayer removeAllGraphics];
	
    if (routeResult)
    {
        AGSGraphic *routeGraphic = [AGSGraphic graphicWithGeometry:routeResult.directions.mergedGeometry
                                                            symbol:self.routeSymbol
                                                        attributes:nil
                                              infoTemplateDelegate:nil];
        [self.routeGraphicsLayer addGraphic:routeGraphic withID:@"RouteShape"];
        
        for (AGSStopGraphic *stopGraphic in routeResult.stopGraphics)
        {
            NSLog(@"Route Stop Point: \"%@\"", stopGraphic.name);
            NSLog(@"Stop point attribtues:\n%@", stopGraphic.attributes);
            if (stopGraphic.sequence == 1)//.name isEqualToString:kEQSRoutingStartPointName])
            {
				[self setStartGraphic:stopGraphic];
            }
            else if (stopGraphic.sequence == routeResult.stopGraphics.count)//.name isEqualToString:kEQSRoutingEndPointName])
            {
				[self setEndGraphic:stopGraphic];
            }
        }
        
        [self.mapView zoomToGeometry:routeResult.routeGraphic.geometry withPadding:100 animated:YES];
    }
    
    [self.routeGraphicsLayer dataChanged];
}

- (AGSGraphic *) setStartPoint:(AGSPoint *)startPoint
{
	AGSGraphic *startGraphic = nil;
	if (startPoint)
	{
		startGraphic = [AGSGraphic graphicWithGeometry:startPoint
												symbol:self.startSymbol
											attributes:nil
								  infoTemplateDelegate:self.startPointCalloutTemplate];
	}
	[self setStartGraphic:startGraphic];
	return startGraphic;
}

- (void) setStartGraphic:(AGSGraphic *)startGraphic
{
	[self.routeGraphicsLayer removeGraphicsByID:kEQSRouteDisplayHelperGraphic_RouteStartPoint];
	if (startGraphic)
	{
		startGraphic.symbol = self.startSymbol;
		startGraphic.infoTemplateDelegate = self.startPointCalloutTemplate;
		[self.routeGraphicsLayer addGraphic:startGraphic withID:kEQSRouteDisplayHelperGraphic_RouteStartPoint];
	}
}

- (AGSGraphic *) setEndPoint:(AGSPoint *)endPoint
{
	AGSGraphic *endGraphic = nil;
	if (endPoint)
	{
		endGraphic = [AGSGraphic graphicWithGeometry:endPoint
											  symbol:self.endSymbol
										  attributes:nil
								infoTemplateDelegate:self.endPointCalloutTemplate];
	}
	[self setEndGraphic:endGraphic];
	return endGraphic;
}

- (void) setEndGraphic:(AGSGraphic *)endGraphic
{
	[self.routeGraphicsLayer removeGraphicsByID:kEQSRouteDisplayHelperGraphic_RouteEndPoint];
	if (endGraphic)
	{
		endGraphic.symbol = self.endSymbol;
		endGraphic.infoTemplateDelegate = self.endPointCalloutTemplate;
		[self.routeGraphicsLayer addGraphic:endGraphic withID:kEQSRouteDisplayHelperGraphic_RouteEndPoint];
	}
}

- (void) clearRouteResult
{
    self.currentRouteResult = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSRouteDisplayNotification_RouteCleared object:self];
}

- (void) zoomToRouteResult
{
    AGSGraphic *routeGraphic = [self.routeGraphicsLayer getGraphicForID:@"RouteShape"];
    if (routeGraphic)
    {
        [self.mapView zoomToGeometry:routeGraphic.geometry withPadding:100 animated:YES];
    }
}

- (void) editRoute
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSRouteDisplayNotification_EditRequested object:self];
}


#pragma mark - RouteDisplayDelegate
- (void) direction:(AGSDirectionGraphic *)direction selectedFromRouteResult:(AGSRouteResult *)routeResult
{
    NSLog(@"%@", direction);
    AGSGraphicsLayer *routeDisplayLayer = self.routeGraphicsLayer;
    [routeDisplayLayer removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *graphic) {
        return [graphic.attributes objectForKey:@"DirectionStepGraphic"] != nil;
    }];
    
    if ([direction.geometry isKindOfClass:[AGSPolyline class]])
    {
        AGSPolyline *directionLine = (AGSPolyline *)direction.geometry;
        AGSPoint *startPoint = (AGSPoint *)[directionLine pointOnPath:0 atIndex:0];
        
        direction.symbol = self.mapView.defaultSymbols.routeSegment;
        [routeDisplayLayer addGraphic:direction
                        withAttribute:@"DirectionStepGraphic"
                            withValue:@"Segment"];
        AGSGraphic *dirStartGraphic = [AGSGraphic graphicWithGeometry:startPoint
                                                               symbol:self.mapView.defaultSymbols.routeSegmentStart
                                                           attributes:nil
                                                 infoTemplateDelegate:nil];
        [routeDisplayLayer addGraphic:dirStartGraphic
                        withAttribute:@"DirectionStepGraphic"
                            withValue:@"StartPoint"];
        [self.mapView zoomToGeometry:direction.geometry withPadding:100 animated:YES];

        if (!self.inSetupStack)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kEQSRouteDisplayNotification_StepSelected object:self];
        }
    }
}

#pragma mark - Internal init/dealloc, etc.
- (id) initForMapView:(AGSMapView *)mapView
{
    self = [self init];
    if (self)
    {
		// Create a new Graphics Layer
        self.routeGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [EQSHelper queueBlock:^{
            [mapView addMapLayer:self.routeGraphicsLayer withName:kEQSRouteResultsLayerName];
        }
           untilMapViewLoaded:mapView];
		
		// Load the symbols we need, but don't block the main thread or the map might not load
		// immediately. This is some tight coupling, but since this is all part of the starter library,
		// this is just about OK.
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            self.startSymbol = mapView.defaultSymbols.routeStart;
            self.endSymbol = mapView.defaultSymbols.routeEnd;
            self.routeSymbol = mapView.defaultSymbols.route;
		});
		
		// Keep a handle onto our AGSMapView
		self.mapView = mapView;

        self.startPointCalloutTemplate = [[AGSCalloutTemplate alloc] init];
        self.startPointCalloutTemplate.titleTemplate = @"Start";
        self.startPointCalloutTemplate.detailTemplate = @"Oooh"; //TODO - fix this
        
        self.endPointCalloutTemplate = [[AGSCalloutTemplate alloc] init];
        self.endPointCalloutTemplate.titleTemplate = @"End";
        self.endPointCalloutTemplate.detailTemplate = @"Ahhh"; //TODO - fix this
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
    
    self.startPointCalloutTemplate = nil;
    self.endPointCalloutTemplate = nil;
}

- (void) addRouteResultsLayer
{
	 [self.mapView addMapLayer:self.routeGraphicsLayer withName:kEQSRouteResultsLayerName];
}
@end