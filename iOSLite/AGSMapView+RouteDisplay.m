//
//  AGSMapView+RouteDisplay.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+RouteDisplay.h"
#import "AGSMapView+GeneralUtilities.h"
#import "EQSHelper.h"
#import "EQSRouteDisplayHelper.h"
#import "EQSGeoServices.h"

@implementation AGSMapView (RouteDisplay)
EQSRouteDisplayHelper *_eqsRouteHelper = nil;

#pragma mark - Properties
- (EQSRouteDisplayHelper *)routeDisplayHelper
{
	if (!_eqsRouteHelper)
	{
		_eqsRouteHelper = [EQSRouteDisplayHelper routeDisplayHelperForMapView:self];
	}
	return _eqsRouteHelper;
}
@end