//
//  AGSMapView+LiteNavigation.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (EQSNavigation)
- (void) centerAtLat:(double)latitude lon:(double)longitude animated:(BOOL)animated;

- (void) zoomToLevel:(NSUInteger)level animated:(BOOL)animated;
- (void) zoomToLevel:(NSUInteger)level withCenterPoint:(AGSPoint *)centerPoint animated:(BOOL)animated;
- (void) zoomToLevel:(NSUInteger)level withLat:(double)latitude lon:(double)longitude animated:(BOOL)animated;

- (void) centerAtMyLocation;
- (void) centerAtMyLocationWithZoomLevel:(NSUInteger)level;

// This will return a "Lat Long" centerpoint. That is, one in WGS84 Spatial reference.
- (AGSPoint *) getCenterPoint;
- (NSUInteger) getZoomLevel;
@end