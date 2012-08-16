//
//  AGSMapView+RouteDisplay.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+RouteDisplay.h"
#import "AGSMapView+GeneralUtilities.h"
#import "STXHelper.h"
#import "STXRouteDisplayHelper.h"
#import "STXGeoServices.h"

@implementation AGSMapView (RouteDisplay)
STXRouteDisplayHelper *_stxRouteHelper = nil;

#pragma mark - Properties
- (STXRouteDisplayHelper *)routeDisplayHelper
{
	if (!_stxRouteHelper)
	{
		_stxRouteHelper = [STXRouteDisplayHelper routeDisplayHelperForMapView:self];
	}
	return _stxRouteHelper;
}
@end