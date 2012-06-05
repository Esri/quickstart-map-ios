//
//  EDNLitRouteTaskHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNLiteRouteTaskHelper.h"

@interface EDNLiteRouteTaskHelper ()<AGSRouteTaskDelegate>

#define kEdnLiteRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEdnLiteRouteTaskHelperNotificationLoaded @"EDNLiteRouteTaskHelperLoaded"
#define kEdnLiteRouteTaskHelperNotificationRouteSolved @"EDNLiteRouteTaskHelperRouteSolved"

@property (nonatomic, retain) AGSRouteTask *routeTaskForParameters;
@property (nonatomic, retain) AGSPoint *startPoint;
@property (nonatomic, retain) AGSPoint *stopPoint;
@property (assign) BOOL waitingToStart;
@end

@implementation EDNLiteRouteTaskHelper
@synthesize routeTask = _routeTask;
@synthesize routeTaskForParameters = _routeTaskForParameters;
@synthesize defaultParameters = _defaultParameters;

@synthesize loaded = _loaded;
@synthesize delegate = _delegate;

@synthesize resultsGraphicsLayer = _resultsGraphicsLayer;

@synthesize startPoint = _startPoint;
@synthesize stopPoint = _stopPoint;

@synthesize waitingToStart = _waitingToStart;

#pragma mark - Init/Dealloc
- (id) initWithDefaultRouteTask
{
    if ([self init])
    {
        self.waitingToStart = NO;
        self.resultsGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        // We create a new route task here. Behind the scenes, we'll create an identical AGSRouteTask,
        // get the default parameters from that, and then store those on this helper while we release
        // that temporary AGSRouteTask and shift focus to this.
        //
        // This is the problem with the single delegate model. Notifications FTW!
        self.routeTask = [AGSRouteTask routeTaskWithURL:[NSURL URLWithString:kEdnLiteRouteTaskUrl]];
    }    
    
    return self;
}

- (void) dealloc
{
    self.routeTask = nil;
    self.routeTaskForParameters = nil;
    self.defaultParameters = nil;

    self.delegate = nil;

    self.resultsGraphicsLayer = nil;

    self.startPoint = nil;
    self.stopPoint = nil;
}

#pragma mark - Public static shortcut
+ (EDNLiteRouteTaskHelper *) ednLiteRouteTaskHelper
{
    return [[EDNLiteRouteTaskHelper alloc] initWithDefaultRouteTask];
}


#pragma mark - Public Functions
- (void) setStart:(AGSPoint *)startPoint AndStop:(AGSPoint *)stopPoint
{
    self.startPoint = startPoint;
    self.stopPoint = stopPoint;
    [self markLoadedIfPossible];
}

- (AGSRouteTaskParameters *) getParameters
{
    return [self getParametersToRouteFromStart:self.startPoint ToStop:self.stopPoint];
}

- (AGSRouteTaskParameters *) getParametersToRouteFromStart:(AGSPoint *)startPoint ToStop:(AGSPoint *)stopPoint
{
    AGSSimpleMarkerSymbol *startSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    AGSSimpleMarkerSymbol *endSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    
    // Set up and name a couple of stops.
    AGSStopGraphic *firstStop = [AGSStopGraphic graphicWithGeometry:startPoint
                                                             symbol:startSymbol
                                                         attributes:nil
                                               infoTemplateDelegate:nil];
    
    AGSStopGraphic *lastStop = [AGSStopGraphic graphicWithGeometry:stopPoint
                                                            symbol:endSymbol
                                                        attributes:nil
                                              infoTemplateDelegate:nil];
    
    firstStop.name = @"Start Point";
    lastStop.name = @"End Point";
    
    // Add them to the parameters.
    NSArray *routeStops = [NSArray arrayWithObjects:firstStop, lastStop, nil];
    AGSRouteTaskParameters *params = self.defaultParameters;
    [params setStopsWithFeatures:routeStops];
    params.returnStopGraphics = YES;
    params.outSpatialReference = [AGSSpatialReference webMercatorSpatialReference];
    
    return params;
}

#pragma mark - Properties
- (BOOL) loaded
{
    return _loaded;
}

- (void) setLoaded:(BOOL)loaded
{
    _loaded = loaded;
    if (_loaded && self.waitingToStart)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEdnLiteRouteTaskHelperNotificationLoaded object:self];
        self.waitingToStart = NO;
    }
}

- (void) markLoadedIfPossible
{
    if (self.defaultParameters &&
        self.startPoint &&
        self.stopPoint)
    {
        self.loaded = YES;
    }
}

- (id<AGSRouteTaskDelegate>) delegate
{
    return _delegate;
}

- (void) setDelegate:(id<AGSRouteTaskDelegate>)delegate
{
    _delegate = delegate;
    [self markLoadedIfPossible];
}

- (void) setRouteTask:(AGSRouteTask *)routeTask
{
    self.loaded = NO;
    
    if (_routeTask)
    {
        _routeTask.delegate = nil;
    }
    
    _routeTask = routeTask;
    if (_routeTask)
    {
        _routeTask.delegate = self;

        // Create a separate route task just for getting the default parameters.
        // The parameters will work with both route tasks since they're based off the same URL.
        self.routeTaskForParameters = [AGSRouteTask routeTaskWithURL:_routeTask.URL];
    }
}

- (void) setRouteTaskForParameters:(AGSRouteTask *)routeTaskForParameters
{
    if (_routeTaskForParameters)
    {
        _routeTaskForParameters.delegate = nil;
    }
    
    _routeTaskForParameters = routeTaskForParameters;
    
    if (routeTaskForParameters)
    {
        _routeTaskForParameters.delegate = self;
        [_routeTaskForParameters retrieveDefaultRouteTaskParameters];
    }
}

- (void) setDefaultParameters:(AGSRouteTaskParameters *)defaultParameters
{
    _defaultParameters = defaultParameters;
    self.routeTaskForParameters = nil;
    [self markLoadedIfPossible];
}

- (void)routeTaskReadyForRouting:(NSNotification *)notification
{
    // Stop waiting, in case we were.
    self.waitingToStart = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // We got the notification that the RoutingHelper has finished loading. We're now ready to
    // use the routing tasks's default parameters, add our stops, and send the routing request.
    // The routing result will be handled by the handler that was passed into the main call.
    
    // And fire off the request to do the routing.
    NSLog(@"Firing off route request");
    [self.routeTask solveWithParameters:[self getParametersToRouteFromStart:self.startPoint ToStop:self.stopPoint]];
}

- (void) solveRouteWhenReady
{
    if (self.loaded)
    {
        // Do it now.
        [self routeTaskReadyForRouting:nil];
    }
    else {
        // Watch for notification and do it when we *are* ready.
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(routeTaskReadyForRouting:) 
                                                     name:kEdnLiteRouteTaskHelperNotificationLoaded 
                                                   object:self];
        self.waitingToStart = YES;
    }
}


#pragma mark - Internal Delegate Handler (Default RouteTaskParameters)
- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams
{
    if (routeTask == self.routeTaskForParameters)
    {
        NSLog(@"Got Default Route Task Parameters");
        self.defaultParameters = routeParams;
    }
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
    if (routeTask == self.routeTaskForParameters)
    {
        NSLog(@"Error getting RouteTaskParameters for EDNLite, using default. Error: %@", error);
        // Something went wrong loading parameters, let's just try with some of our own.
        // They'll be blank, but will hopefully work with the route task.
        self.defaultParameters = [AGSRouteTaskParameters routeTaskParameters];
    }
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
    if (routeTask == self.routeTask)
    {
        NSLog(@"Got route results");
        // Reset our internal status.
        self.waitingToStart = NO;
        
        [self.resultsGraphicsLayer removeAllGraphics];
        AGSRouteResult *result = [routeTaskResult.routeResults objectAtIndex:0];
        AGSGraphic *routeGraphic = result.routeGraphic;
        
        AGSSimpleLineSymbol *routeSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7f] width:8.0f];
        
        routeGraphic.symbol = routeSymbol;
        
        [self.resultsGraphicsLayer addGraphic:routeGraphic];
        for (AGSGraphic *stopGraphic in result.stopGraphics) {
            [self.resultsGraphicsLayer addGraphic:stopGraphic];
        }
        
        [self.resultsGraphicsLayer dataChanged];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:result forKey:@"routeResult"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEdnLiteRouteTaskHelperNotificationRouteSolved object:self userInfo:userInfo];
        
        if (self.delegate)
        {
            if ([self.delegate respondsToSelector:@selector(routeTask:operation:didSolveWithResult:)])
            {
                [self.delegate routeTask:routeTask operation:op didSolveWithResult:routeTaskResult];
            }
        }
    }
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error
{
    NSLog(@"Failed to get route: %@", error);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEdnLiteRouteTaskHelperNotificationRouteSolved object:self userInfo:userInfo];
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(routeTask:operation:didFailSolveWithError:)])
        {
            [self.delegate routeTask:routeTask operation:op didFailSolveWithError:error];
        }
    }

}
@end