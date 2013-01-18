//
//  AGSMapView+LiteNavigation.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (EQSNavigation)
// Add a method to go with centerAtPoint:animated: that allows lat/lon as input.
- (void) centerAtLat:(double)latitude lon:(double)longitude animated:(BOOL)animated;

// Add to the existing zoomTo... methods with a set of zoomToLevel methods.
- (void) zoomToLevel:(NSUInteger)level animated:(BOOL)animated;
- (void) zoomToLevel:(NSUInteger)level withCenterPoint:(AGSPoint *)centerPoint animated:(BOOL)animated;
- (void) zoomToLevel:(NSUInteger)level withLat:(double)latitude lon:(double)longitude animated:(BOOL)animated;

- (void) zoomToPlace:(NSString *)searchString animated:(BOOL)animated;

// Add some methods to center and zoom to a device's geolocation. See also the EQSGeoServices class.
- (void) centerAtMyLocation;
- (void) centerAtMyLocationWithZoomLevel:(NSUInteger)level;

// Return the centerpoint of the map's current visible extent.
@property (nonatomic, assign) AGSPoint *centerPoint;
// Get the map's nearest zoom level (an integer in the range 1-20).
@property (nonatomic, assign) NSUInteger zoomLevel;
@end
