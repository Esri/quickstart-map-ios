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
#import "AGSMapView+EQSGraphics.h"
#import "AGSGraphicsLayer+EQSGraphics.h"
#import "EQSGeoServices.h"
#import "EQSDefaultSymbols.h"

#import "EQSRouteResultsViewController.h"

#define kEQSRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEQSRouteTaskHelperNotificationLoaded @"EQSRouteTaskHelperLoaded"
#define kEQSRouteTaskHelperNotificationRouteSolved @"EQSRouteTaskHelperRouteSolved"

#define kEQSRouteResultsLayerName @"EQSRouteResults"

@interface EQSRouteDisplayHelper () <EQSRouteDisplayViewDelegate>
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

@synthesize tableVC = _tableVC;

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
        
        AGSGraphic *routeGraphic = [AGSGraphic graphicWithGeometry:result.directions.mergedGeometry
                                                            symbol:self.routeSymbol
                                                        attributes:nil
                                              infoTemplateDelegate:nil];
        [self.routeGraphicsLayer addGraphic:routeGraphic withID:@"RouteShape"];
		
        for (AGSStopGraphic *stopGraphic in result.stopGraphics)
        {
            NSString *routeStopID = nil;
            NSLog(@"Route Stop Point: \"%@\"", stopGraphic.name);
            NSLog(@"Stop point attribtues:\n%@", stopGraphic.attributes);
            if (stopGraphic.sequence == 1)//.name isEqualToString:kEQSRoutingStartPointName])
            {
                stopGraphic.symbol = self.startSymbol;
                stopGraphic.infoTemplateDelegate = self.startPointCalloutTemplate;
                routeStopID = @"RouteStart";
            }
            else if (stopGraphic.sequence == result.stopGraphics.count)//.name isEqualToString:kEQSRoutingEndPointName])
            {
                stopGraphic.symbol = self.endSymbol;
                stopGraphic.infoTemplateDelegate = self.endPointCalloutTemplate;
                routeStopID = @"RouteEnd";
            }
            [self.routeGraphicsLayer addGraphic:stopGraphic withID:routeStopID];
        }
        
        [self setupTabularDisplay:result];
        [self.mapView zoomToGeometry:result.routeGraphic.geometry withPadding:100 animated:YES];
        [self.routeGraphicsLayer dataChanged];
    }
}

- (void) setTableVC:(EQSRouteResultsViewController *)tableVC
{
    _tableVC = tableVC;
    if (_tableVC)
    {
        if (_tableVC.routeDisplayDelegate == nil)
        {
            _tableVC.routeDisplayDelegate = self;
        }
    }
}

- (void) setupTabularDisplay:(AGSRouteResult *)routeResult
{
    if (self.tableVC)
    {
        self.tableVC.routeResult = routeResult;
    }
}

- (void) clearRouteResult
{
    [self.routeGraphicsLayer removeAllGraphics];
    [self.routeGraphicsLayer dataChanged];
}

- (void) zoomToRouteResult
{
    AGSGraphic *routeGraphic = [self.routeGraphicsLayer getGraphicForID:@"RouteShape"];
    if (routeGraphic)
    {
        [self.mapView zoomToGeometry:routeGraphic.geometry withPadding:100 animated:YES];
    }
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
		[mapView addMapLayer:self.routeGraphicsLayer withName:kEQSRouteResultsLayerName];
		
		// Keep a handle onto our AGSMapView
		self.mapView = mapView;

		// Set up the default symbols.
        self.startSymbol = mapView.defaultSymbols.routeStart;
        self.endSymbol = mapView.defaultSymbols.routeEnd;
        
		self.routeSymbol = mapView.defaultSymbols.route;
        
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