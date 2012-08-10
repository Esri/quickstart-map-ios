//
//  AGSMapView+RouteDisplay.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+RouteDisplay.h"
#import "AGSMapView+GeneralUtilities.h"
#import "EDNLiteHelper.h"
#import "EDNRouteDisplayHelper.h"
#import "AGSStarterGeoServices.h"

@implementation AGSMapView (RouteDisplay)
EDNRouteDisplayHelper *_ednLiteRouteHelper = nil;

#pragma mark - Properties
- (EDNRouteDisplayHelper *)routeDisplayHelper
{
	if (!_ednLiteRouteHelper)
	{
		_ednLiteRouteHelper = [EDNRouteDisplayHelper ednLiteRouteDisplayHelperForMapView:self];
	}
	return _ednLiteRouteHelper;
}
@end