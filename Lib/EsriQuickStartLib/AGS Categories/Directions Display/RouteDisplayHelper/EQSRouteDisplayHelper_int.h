//
//  EQSRouteDisplayHelper_int.h
//  EsriQuickStartLib
//
//  Created by Nicholas Furness on 1/17/13.
//
//

#import "EQSRouteDisplayHelper.h"

@interface EQSRouteDisplayHelper (EQSInternal)
// Use this method to instantiate a new RouteDisplayHelper for a given AGSMapView
+ (EQSRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView;
@end