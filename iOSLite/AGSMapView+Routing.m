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
EDNLiteRouteTaskHelper *_ednLiteRouteHelper = nil;

#pragma mark - Properties
- (EDNLiteRouteTaskHelper *)routeTaskHelper
{
	if (!_ednLiteRouteHelper)
	{
		_ednLiteRouteHelper = [EDNLiteRouteTaskHelper ednLiteRouteTaskHelperForMapView:self];
	}
	return _ednLiteRouteHelper;
}

#pragma mark - Public Methods

- (AGSGraphic *) showRouteResults:(AGSRouteTaskResult *)routeTaskResults;
{
    AGSRouteResult *result = [routeTaskResults.routeResults objectAtIndex:0];
    if (result)
    {
		[self.routeTaskHelper.routeGraphicsLayer removeAllGraphics];

        AGSRouteResult *result = [routeTaskResults.routeResults objectAtIndex:0];
        AGSGraphic *routeGraphic = result.routeGraphic;
        AGSSimpleLineSymbol *routeSymbol = self.routeTaskHelper.routeSymbol;
        routeGraphic.symbol = routeSymbol;
        
        [self.routeTaskHelper.routeGraphicsLayer addGraphic:routeGraphic];

        for (AGSStopGraphic *stopGraphic in result.stopGraphics) {
            NSLog(@"Route Stop Point: \"%@\"", stopGraphic.name);
            if ([stopGraphic.name isEqualToString:kEDNLiteRoutingStartPointName])
            {
                stopGraphic.symbol = self.routeTaskHelper.startSymbol;
            }
            else if ([stopGraphic.name isEqualToString:kEDNLiteRoutingEndPointName])
            {
                stopGraphic.symbol = self.routeTaskHelper.endSymbol;
            }
            [self.routeTaskHelper.routeGraphicsLayer addGraphic:stopGraphic];
        }
        
        [self.routeTaskHelper.routeGraphicsLayer dataChanged];
		
        [self zoomToGeometry:result.routeGraphic.geometry withPadding:100 animated:YES];
		return result.routeGraphic;
    }
	return nil;
}

 - (void) clearRoute
{
    [self.routeTaskHelper.routeGraphicsLayer removeAllGraphics];
    [self.routeTaskHelper.routeGraphicsLayer dataChanged];
}

#pragma mark - Properties
- (AGSSymbol *) routeStartSymbol
{
	return self.routeTaskHelper.startSymbol;
}

- (AGSSymbol *) routeStopSymbol
{
	return self.routeTaskHelper.endSymbol;
}

- (AGSSymbol *) routeSymbol
{
	return self.routeTaskHelper.routeSymbol;
}

- (void) setRouteStartSymbol:(AGSMarkerSymbol *)defaultRouteStartSymbol
{
	self.routeTaskHelper.startSymbol = defaultRouteStartSymbol;
}

- (void) setRouteStopSymbol:(AGSMarkerSymbol *)defaultRouteStopSymbol
{
	self.routeTaskHelper.endSymbol = defaultRouteStopSymbol;
}

- (void) setRouteSymbol:(AGSSimpleLineSymbol *)defaultRouteSymbol
{
	self.routeTaskHelper.routeSymbol = defaultRouteSymbol;
}

#pragma mark - Internals

- (void) __ednLiteDeallocRouting
{
    // Release the handler instance we've got
    _ednLiteRouteHelper = nil;
}
@end