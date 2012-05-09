//
//  AGSMapView+LiteNavigation.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (LiteNavigation)
- (void) zoomToLat:(double) latitude withLong:(double) longitude;
@end
