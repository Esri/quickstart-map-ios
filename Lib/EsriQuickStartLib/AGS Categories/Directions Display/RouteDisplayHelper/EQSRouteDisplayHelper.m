//
//  EQSRouteDisplayHelper.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteDisplayHelper.h"

#import "EQSHelper_int.h"
#import "AGSMapView+EQSGeneralUtilities.h"
#import "AGSMapView+EQSBasemaps.h"
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
@synthesize endSymbol = _endSymbol;
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
- (void) showRouteResult:(AGSRouteTaskResult *)routeTaskResult
{
	if (routeTaskResult.routeResults.count > 0)
	{
		[self.routeGraphicsLayer removeAllGraphics];
		
        AGSRouteResult *result = [routeTaskResult.routeResults objectAtIndex:0];
        
        self.currentRouteResult = result;
    }
}

- (void) registerHandler:(id)object forDirEdit:(SEL)editMethod clearDirs:(SEL)clearMethod andDirStep:(SEL)dirStepMethod
{
	if (editMethod)
	{
		[[NSNotificationCenter defaultCenter] addObserver:object
												 selector:editMethod
													 name:kEQSRouteDisplayNotification_EditRequested
												   object:self];
	}
	if (clearMethod)
	{
		[[NSNotificationCenter defaultCenter] addObserver:object
												 selector:clearMethod
													 name:kEQSRouteDisplayNotification_RouteCleared
												   object:self];
	}
	if (dirStepMethod)
	{
		[[NSNotificationCenter defaultCenter] addObserver:object
												 selector:dirStepMethod
													 name:kEQSRouteDisplayNotification_StepSelected
												   object:self];
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
            if (stopGraphic.sequence == 1)
            {
				[self setStartGraphic:stopGraphic];
            }
            else if (stopGraphic.sequence == routeResult.stopGraphics.count)
            {
				[self setEndGraphic:stopGraphic];
            }
        }
        
        [self.mapView zoomToGeometry:routeResult.routeGraphic.geometry withPadding:100 animated:YES];
    }
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
//    NSLog(@"%@", direction);
    AGSGraphicsLayer *routeDisplayLayer = self.routeGraphicsLayer;
    [routeDisplayLayer removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *graphic) {
        return [graphic hasAttributeForKey:@"DirectionStepGraphic"];
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
    self = [super init];
    if (self)
    {
		// Create a new Graphics Layer
        self.routeGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [EQSHelper queueBlock:^{
            [mapView addMapLayer:self.routeGraphicsLayer withName:kEQSRouteResultsLayerName];
        }
           untilMapViewLoaded:mapView
                withBlockName:@"Adding route graphics layer"];
		
		// Load the symbols we need, but don't block the main thread or the map might not load
		// immediately. This is some tight coupling, but since this is all part of the starter library,
		// this is just about OK.
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            @synchronized(self)
            {
                self.startSymbol = mapView.defaultSymbols.routeStart;
                self.endSymbol = mapView.defaultSymbols.routeEnd;
                self.routeSymbol = mapView.defaultSymbols.route;
            };
//            NSLog(@"#### Loaded Route Symbols");
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

- (void) setStartSymbol:(AGSMarkerSymbol *)startSymbol
{
    _startSymbol = startSymbol;
}

- (AGSMarkerSymbol *) startSymbol
{
    @synchronized(self)
    {
        return _startSymbol;
    }
}

- (void) setEndSymbol:(AGSMarkerSymbol *)endSymbol
{
    _endSymbol = endSymbol;
}

- (AGSMarkerSymbol *) endSymbol
{
    @synchronized(self)
    {
        return _endSymbol;
    }
}

- (void) setRouteSymbol:(AGSSimpleLineSymbol *)routeSymbol
{
    _routeSymbol = routeSymbol;
}

- (AGSSimpleLineSymbol *) routeSymbol
{
    @synchronized(self)
    {
        return _routeSymbol;
    }
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