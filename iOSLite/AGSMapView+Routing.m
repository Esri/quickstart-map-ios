//
//  AGSMapView+Routing.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Routing.h"
#import "EDNLiteHelper.h"
#import "EDNLitRouteTaskHelper.h"

@implementation AGSMapView (Routing)
EDNLiteRouteTaskHelper *__ednLiteRouteHelper = nil;

#pragma mark - Public Methods
- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint
{
    [self getDirectionsFromPoint:startPoint ToPoint:stopPoint WithHandler:nil];
}

- (void)getDirectionsFromLat:(double)startLat Lon:(double)startLon ToLat:(double)stopLat Lon:(double)stopLon
{    
    [self getDirectionsFromPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:startLat Long:startLon]
                         ToPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:stopLat Long:stopLon]];
}

- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint WithHandler:(id<AGSRouteTaskDelegate>)handler
{
    // Set up the route task to respond to the handler we're specifying here.
    // The route task will ask for its default parameters, and when they're returned,
    // the EDNLiteRouteTaskHelperLoaded notification will fire, causing the
    // routeTaskReadyForRouting method below to be called.
    [self __ednLiteInitRoutingWithStartPoint:startPoint stopPoint:stopPoint AndHandler:handler];
}

- (void) getDirectionsFromLat:(double)startLat Lon:(double)startLon ToLat:(double)stopLat Lon:(double)stopLon WithHandler:(id<AGSRouteTaskDelegate>)handler
{    
    [self getDirectionsFromPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:startLat Long:startLon]
                         ToPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:stopLat Long:stopLon]
                     WithHandler:handler];
}

 - (void) clearRoute
{
    [[__ednLiteRouteHelper resultsGraphicsLayer] removeAllGraphics];
    [[__ednLiteRouteHelper resultsGraphicsLayer] dataChanged];
}

#pragma mark - Internals
- (void) __ednLiteInitRoutingWithStartPoint:(AGSPoint *)startPoint stopPoint:(AGSPoint *)stopPoint AndHandler:(id<AGSRouteTaskDelegate>)handler
{
    if (!__ednLiteRouteHelper)
    {
        __ednLiteRouteHelper = [EDNLiteRouteTaskHelper ednLiteRouteTaskHelper];
        [self addMapLayer:[__ednLiteRouteHelper resultsGraphicsLayer] withName:@"EDNLiteRouteResults"];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(__ednLiteRouteSolved:) 
                                                     name:@"EDNLiteRouteTaskHelperRouteSolved" 
                                                   object:__ednLiteRouteHelper];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(__ednLiteRouteBasemapDidChange:) 
                                                     name:@"BasemapDidChange"
                                                   object:self];
    }

    __ednLiteRouteHelper.handler = handler;

    [__ednLiteRouteHelper setStart:startPoint AndStop:stopPoint];    
    [__ednLiteRouteHelper solveRouteWhenReady];
}

- (void) __ednLiteDeallocRouting
{
    __ednLiteRouteHelper = nil;
}

- (void) __ednLiteRouteBasemapDidChange:(NSNotification *)notification
{
    [self addMapLayer:[__ednLiteRouteHelper resultsGraphicsLayer] withName:@"EDNLiteRouteResults"];
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