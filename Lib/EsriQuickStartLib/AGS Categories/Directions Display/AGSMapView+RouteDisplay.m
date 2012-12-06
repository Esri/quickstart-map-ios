//
//  AGSMapView+RouteDisplay.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+RouteDisplay.h"
#import "AGSMapView+EQSGeneralUtilities.h"
#import "EQSHelper.h"
#import "EQSRouteDisplayHelper.h"
#import "EQSGeoServices.h"

#import <objc/runtime.h>

@implementation AGSMapView (EQSDirections)
//#define kEQSRouteDisplayHelperKey @"EQSRouteDisplayHelper"

#pragma mark - Properties
- (EQSRouteDisplayHelper *)routeDisplayHelper
{
    static EQSRouteDisplayHelper *helper = nil; //objc_getAssociatedObject(self, kEQSRouteDisplayHelperKey);
    if (helper == nil)
    {
        helper = [EQSRouteDisplayHelper routeDisplayHelperForMapView:self];
//        objc_setAssociatedObject(self, kEQSRouteDisplayHelperKey, helper, OBJC_ASSOCIATION_RETAIN);
    }
    return helper;
}
@end