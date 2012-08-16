//
//  STXRouteDisplayHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface STXRouteDisplayHelper : NSObject
// Use this method to instantiate a new RouteDisplayHelper for a given AGSMapView
+ (STXRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView;

- (void) showRouteResults:(AGSRouteTaskResult *)routeTaskResults;
- (void) clearRouteDisplay;

@property (nonatomic, retain) AGSGraphicsLayer *routeGraphicsLayer;
@property (nonatomic, retain) AGSMarkerSymbol *startSymbol;
@property (nonatomic, retain) AGSMarkerSymbol *endSymbol;
@property (nonatomic, retain) AGSSimpleLineSymbol *routeSymbol;
@end