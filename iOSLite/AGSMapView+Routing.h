//
//  AGSMapView+Routing.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Routing)
- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint;
- (void)getDirectionsFromLat:(double)startLat Lon:(double)startLon ToLat:(double)stopLat Lon:(double)stopLon;

- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint WithHandler:(id<AGSRouteTaskDelegate>)handler;
- (void)getDirectionsFromLat:(double)startLat Lon:(double)startLon ToLat:(double)endLat Lon:(double)endLon WithHandler:(id<AGSRouteTaskDelegate>)handler;

- (void) clearRoute;
@end
