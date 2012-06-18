//
//  AGSMapView+LiteNavigation.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Navigation)
- (void) centerAtLat:(CGFloat) latitude Long:(CGFloat) longitude;
- (void) centerAtLat:(CGFloat) latitude Long:(CGFloat) longitude withScaleLevel:(NSInteger)scaleLevel;
- (void) centerAtPoint:(AGSPoint *)point withScaleLevel:(NSInteger)scaleLevel;
- (void) zoomToLevel:(NSInteger)level;

- (void) centerAtMyLocation;
- (void) centerAtMyLocationWithScaleLevel:(NSInteger)scaleLevel;

- (AGSPoint *) getLatLongCenterPoint;
- (AGSPoint *) getWebMercatorCenterPoint;
@end