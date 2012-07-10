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

#define kEDNLiteRouteResultsLayerName @"EDNLiteRouteResults"

@implementation AGSMapView (Routing)
EDNLiteRouteTaskHelper *__ednLiteRouteHelper = nil;

#pragma mark - Public Methods
- (void)getDirectionsFromPoint:(AGSPoint *)startPoint
					   ToPoint:(AGSPoint *)stopPoint
{
    [self getDirectionsFromPoint:startPoint ToPoint:stopPoint WithDelegate:nil];
}

- (void)getDirectionsFromLat:(double)startLat Long:(double)startLng 
					   ToLat:(double)stopLat Long:(double)stopLng
{    
    [self getDirectionsFromPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:startLat Long:startLng]
                         ToPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:stopLat Long:stopLng]];
}

- (void)getDirectionsFromPoint:(AGSPoint *)startPoint 
					   ToPoint:(AGSPoint *)stopPoint 
				  WithDelegate:(id<AGSRouteTaskDelegate>)delegate
{
    // Set up the route task to respond to the handler we're specifying here.
    // The route task will ask for its default parameters, and when they're returned,
    // the EDNLiteRouteTaskHelperLoaded notification will fire, causing the
    // routeTaskReadyForRouting method below to be called.
    [self __ednLiteInitRoutingWithStartPoint:startPoint stopPoint:stopPoint AndDelegate:delegate];
}

- (void) getDirectionsFromLat:(double)startLat Long:(double)startLng 
						ToLat:(double)stopLat Long:(double)stopLng 
				 WithDelegate:(id<AGSRouteTaskDelegate>)delegate
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

#pragma mark - Properties
- (AGSSymbol *) defaultRouteStartSymbol
{
	[self __ednLiteInitRouting];
	
	return __ednLiteRouteHelper.startSymbol;
}

- (AGSSymbol *) defaultRouteStopSymbol
{
	[self __ednLiteInitRouting];
	
	return __ednLiteRouteHelper.stopSymbol;
}

- (AGSSymbol *) defaultRouteSymbol
{
	[self __ednLiteInitRouting];
	
	return __ednLiteRouteHelper.routeSymbol;
}

- (void) setDefaultRouteStartSymbol:(AGSMarkerSymbol *)defaultRouteStartSymbol
{
	[self __ednLiteInitRouting];
	
	__ednLiteRouteHelper.startSymbol = defaultRouteStartSymbol;
}

- (void) setDefaultRouteStopSymbol:(AGSMarkerSymbol *)defaultRouteStopSymbol
{
	[self __ednLiteInitRouting];

	__ednLiteRouteHelper.stopSymbol = defaultRouteStopSymbol;
}

- (void) setDefaultRouteSymbol:(AGSSimpleLineSymbol *)defaultRouteSymbol
{
	[self __ednLiteInitRouting];

	__ednLiteRouteHelper.routeSymbol = defaultRouteSymbol;
}

#pragma mark - Internals
- (void) __ednLiteInitRouting
{
    if (!__ednLiteRouteHelper)
    {
        // Get an instance of the route helper class.
        __ednLiteRouteHelper = [EDNLiteRouteTaskHelper ednLiteRouteTaskHelper];
        
        // Add a layer to hold the route results.
		void (^addLayerCode)() = ^void
		{
			[self addMapLayer:[__ednLiteRouteHelper resultsGraphicsLayer] withName:kEDNLiteRouteResultsLayerName];
		};
		
		if (self.loaded)
		{
			// If the mapView is already loaded, just run this code.
			addLayerCode();
		}
		else 
		{
			// Otherwise we queue this block up to be run when self (an AGSMapView) *has* loaded
			// since the behaviour doesn't work before then. This is because the map will not yet 
			// be fully initialized for UI interaction until then.
			[EDNLiteHelper queueBlock:addLayerCode untilMapViewLoaded:self];
		}

        
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
}

- (void) __ednLiteInitRoutingWithStartPoint:(AGSPoint *)startPoint 
								  stopPoint:(AGSPoint *)stopPoint 
								AndDelegate:(id<AGSRouteTaskDelegate>)delegate
{
	[self __ednLiteInitRouting];
	
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

- (void) __ednLiteRouteSolved:(NSNotification *)notification
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