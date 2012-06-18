//
//  AGSMapView+Routing.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Routing.h"
#import "AGSMapView+GeneralUtilities.h"
#import "EDNLiteHelper.h"
#import "EDNLiteRouteTaskHelper.h"

@implementation AGSMapView (Routing)
EDNLiteRouteTaskHelper *__ednLiteRouteHelper = nil;

#define kEDNLiteRouteResultsLayerName @"EDNLiteRouteResults"

#pragma mark - Public Methods
- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint
{
    [self getDirectionsFromPoint:startPoint ToPoint:stopPoint WithDelegate:nil];
}

- (void)getDirectionsFromLat:(double)startLat Lng:(double)startLng ToLat:(double)stopLat Lng:(double)stopLng
{    
    [self getDirectionsFromPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:startLat Long:startLng]
                         ToPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:stopLat Long:stopLng]];
}

- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint WithDelegate:(id<AGSRouteTaskDelegate>)delegate
{
    // Set up the route task to respond to the handler we're specifying here.
    // The route task will ask for its default parameters, and when they're returned,
    // the EDNLiteRouteTaskHelperLoaded notification will fire, causing the
    // routeTaskReadyForRouting method below to be called.
    [self __ednLiteInitRoutingWithStartPoint:startPoint stopPoint:stopPoint AndDelegate:delegate];
}

- (void) getDirectionsFromLat:(double)startLat Lng:(double)startLng ToLat:(double)stopLat Lng:(double)stopLng WithDelegate:(id<AGSRouteTaskDelegate>)delegate
{    
    [self getDirectionsFromPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:startLat Long:startLng]
                         ToPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:stopLat Long:stopLng]
                     WithDelegate:delegate];
}

 - (void) clearRoute
{
    [[__ednLiteRouteHelper resultsGraphicsLayer] removeAllGraphics];
    [[__ednLiteRouteHelper resultsGraphicsLayer] dataChanged];
}

#pragma mark - Internals
- (void) __ednLiteInitRoutingWithStartPoint:(AGSPoint *)startPoint stopPoint:(AGSPoint *)stopPoint AndDelegate:(id<AGSRouteTaskDelegate>)delegate
{
    if (!__ednLiteRouteHelper)
    {
        // Get an instance of the route helper class.
        __ednLiteRouteHelper = [EDNLiteRouteTaskHelper ednLiteRouteTaskHelper];
        
        // Add a layer to hold the route results.
        [self addMapLayer:[__ednLiteRouteHelper resultsGraphicsLayer] withName:kEDNLiteRouteResultsLayerName];
        
        // Register myself as being interested in knowing when the route is solved, so that I can draw it
        // in the graphics layer.
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(__ednLiteRouteSolved:) 
                                                     name:@"EDNLiteRouteTaskHelperRouteSolved" 
                                                   object:__ednLiteRouteHelper];
        
        // And also tell me when the baselayer of the map is changed so that I can re-add the layer if
        // necessary.
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(__ednLiteRouteBasemapDidChange:) 
                                                     name:@"BasemapDidChange"
                                                   object:self];
    }

    // Set me up as the delegate handler for the helper.
    __ednLiteRouteHelper.delegate = delegate;

    // Set the start and end points
    [__ednLiteRouteHelper setStart:startPoint AndStop:stopPoint];    
    
    // And solve the route
    [__ednLiteRouteHelper solveRouteWhenReady];
}

- (void) __ednLiteDeallocRouting
{
    // Release the handler instance we've got
    __ednLiteRouteHelper = nil;
}

- (void) __ednLiteRouteBasemapDidChange:(NSNotification *)notification
{
    // The basemap changed, which means we need to re-add the basemap layer
    if (![self getLayerForName:kEDNLiteRouteResultsLayerName])
    {
        [self addMapLayer:[__ednLiteRouteHelper resultsGraphicsLayer] withName:kEDNLiteRouteResultsLayerName];
    }
}

- (void)__ednLiteRouteSolved:(NSNotification *)notification
{
    AGSRouteResult *result = [notification.userInfo objectForKey:@"routeResult"];
    if (result)
    {
        [self zoomToGeometry:result.routeGraphic.geometry withPadding:100 animated:YES];
    }
    else
    {
        NSError *error = [notification.userInfo objectForKey:@"error"];
        if (error)
        {
            NSLog(@"Error generating route: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not calculate route"
                                                            message:[error.userInfo objectForKey:@"NSLocalizedFailureReason"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}
@end