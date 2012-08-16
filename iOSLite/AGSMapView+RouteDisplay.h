//
//  AGSMapView+Routing.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "STXRouteDisplayHelper.h"

@interface AGSMapView (RouteDisplay)
- (STXRouteDisplayHelper *)routeDisplayHelper;
@end
