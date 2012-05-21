//
//  AGSMapView+LiteNavigation.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Navigation)
- (void) zoomToLat:(double) latitude Long:(double) longitude withScaleLevel:(int)scaleLevel;
- (void) centerAtLat:(double) latitude Long:(double) longitude;
@end
