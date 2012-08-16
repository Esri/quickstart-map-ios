//
//  AGSMapView+GeoServices.m
//  iOSLite
//
//  Created by Nicholas Furness on 8/10/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+GeoServices.h"

@implementation AGSMapView (GeoServices)
STXGeoServices *__agsStarterGeoServices = nil;

- (STXGeoServices *) geoServices
{
	if (!__agsStarterGeoServices)
	{
		__agsStarterGeoServices = [[STXGeoServices alloc] init];
	}
	return __agsStarterGeoServices;
}
@end
