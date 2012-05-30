//
//  AGSMapView+LiteNavigation.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Navigation)
- (void) centerAtLat:(double) latitude Lng:(double) longitude;
- (void) centerAtLat:(double) latitude Lng:(double) longitude withScaleLevel:(int)scaleLevel;

- (void) centerAtMyLocation;
//- (void) centerAtMyLocationWithScaleLevel:(int)scaleLevel;
@end
