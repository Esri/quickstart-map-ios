//
//  AGSMapView+RouteDisplay.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+EQSRouteDisplay.h"
#import "AGSMapView+EQSGeneralUtilities.h"
#import "EQSHelper.h"
#import "EQSRouteDisplayHelper_int.h"
#import "EQSGeoServices.h"

#import <objc/runtime.h>

@implementation AGSMapView (EQSDirections)

#pragma mark - Properties
- (EQSRouteDisplayHelper *)routeDisplayHelper
{
    static EQSRouteDisplayHelper *helper = nil;
    if (helper == nil)
    {
        helper = [EQSRouteDisplayHelper routeDisplayHelperForMapView:self];
    }
    return helper;
}
@end