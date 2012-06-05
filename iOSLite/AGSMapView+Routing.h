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
- (void)getDirectionsFromLat:(double)startLat Lng:(double)startLon ToLat:(double)stopLat Lng:(double)stopLng WithDelegate:(id<AGSRouteTaskDelegate>)delegate;

- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint;
- (void)getDirectionsFromPoint:(AGSPoint*)startPoint ToPoint:(AGSPoint *)stopPoint WithDelegate:(id<AGSRouteTaskDelegate>)delegate;

- (void) clearRoute;
@end
