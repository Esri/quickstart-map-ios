//
//  AGSMapView+Graphics.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNLiteHelper.h"

typedef enum {
    EDNLiteGraphicsLayerTypePoint = 1,
    EDNLiteGraphicsLayerTypePolyline = 2,
    EDNLiteGraphicsLayerTypePolygon = 4
} EDNLiteGraphicsLayerType;

@interface AGSMapView (Graphics)
- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude;
- (AGSGraphic *) addLineWithLatsAndLongs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION;
- (AGSGraphic *) addPolygonWithLatsAndLongs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION;
- (void) clearGraphics:(EDNLiteGraphicsLayerType)layerType;
- (void) clearGraphics;
@end
