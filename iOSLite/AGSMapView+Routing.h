//
//  AGSMapView+Routing.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Routing)
- (void)getDirectionsFromLat:(double)startLat Lng:(double)startLng ToLat:(double)stopLat Lng:(double)stopLng;
- (void)getDirectionsFromLat:(double)startLat Lng:(double)startLon ToLat:(double)stopLat Lng:(double)stopLng WithHandler:(id<AGSRouteTaskDelegate>)handler;

- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint;
- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint WithHandler:(id<AGSRouteTaskDelegate>)handler;

- (void) clearRoute;
@end
