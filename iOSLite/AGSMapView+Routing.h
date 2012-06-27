//
//  AGSMapView+Routing.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Routing)
// Get directions and put them on the map.
- (void)getDirectionsFromLat:(double)startLat Long:(double)startLng 
					   ToLat:(double)stopLat Long:(double)stopLng;
- (void)getDirectionsFromPoint:(AGSPoint *)startPoint 
					   ToPoint:(AGSPoint *)stopPoint;

// Get directions, put them on the map, and be alerted with further information about them (pass in an object
// that implements the AGSRouteTaskDelegate).
- (void)getDirectionsFromLat:(double)startLat Long:(double)startLon 
					   ToLat:(double)stopLat Long:(double)stopLng 
				WithDelegate:(id<AGSRouteTaskDelegate>)delegate;
- (void)getDirectionsFromPoint:(AGSPoint *)startPoint 
					   ToPoint:(AGSPoint *)stopPoint 
				  WithDelegate:(id<AGSRouteTaskDelegate>)delegate;

// Clear the route from the map.
- (void) clearRoute;
@end
