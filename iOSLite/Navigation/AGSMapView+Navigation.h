//
//  AGSMapView+LiteNavigation.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Navigation)
- (void) centerAtLat:(CGFloat) latitude Lng:(CGFloat) longitude;
- (void) centerAtLat:(CGFloat) latitude Lng:(CGFloat) longitude withScaleLevel:(NSInteger)scaleLevel;

- (void) centerAtMyLocation;
- (void) centerAtMyLocationWithScaleLevel:(NSInteger)scaleLevel;

- (void) zoomToLevel:(NSInteger)level;

- (AGSPoint *) getCenterPoint;
- (AGSPoint *) getCenterPointWebMercator;
@end