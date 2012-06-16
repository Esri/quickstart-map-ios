//
//  AGSMapView+Graphics.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

typedef enum {
    EDNLiteGraphicsLayerTypePoint = 1,
    EDNLiteGraphicsLayerTypePolyline = 2,
    EDNLiteGraphicsLayerTypePolygon = 4
} EDNLiteGraphicsLayerType;

@interface AGSMapView (Graphics)
- (AGSGraphic *) addPointAtLat:(double)latitude Lng:(double)longitude;
- (AGSGraphic *) addLineWithLatsAndLngs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION;
- (AGSGraphic *) addPolygonWithLatsAndLngs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION;

- (void) clearGraphics:(EDNLiteGraphicsLayerType)layerType;
- (void) clearGraphics;

- (AGSGraphic *) editGraphicFromDidClickAtPointEvent:(NSDictionary *)graphics;
- (void) saveCurrentEdit;
- (void) cancelCurrentEdit;
- (NSUndoManager *) getUndoManagerForGraphicsEdits;
- (AGSGeometry *) getCurrentEditGeometry;
@end
