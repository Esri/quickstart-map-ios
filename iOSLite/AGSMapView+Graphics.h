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

// Create graphics using sequences of lat/long coordinates.
- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude;
- (AGSGraphic *) addPoint:(AGSPoint *)point;
- (AGSGraphic *) addLineFromPoints:(NSArray *) points;
- (AGSGraphic *) addPolygonFromPoints:(NSArray *) points;

// Remove individual graphics
- (void) removeGraphic:(AGSGraphic *)graphic;

// Clear graphics from the map. Optionally specify what type or types of graphics to clear.
- (void) clearGraphics:(EDNLiteGraphicsLayerType)layerType;
- (void) clearGraphics;

// Start editing a graphic/shape
// Call this from the mapView:DidClickAtPoint:mapPoint:graphics handled of AGSMapViewTouchDelegate
// to automatically work out which graphic to edit and start editing it. The selected graphic will 
// be returned, and the geometry put into an edit state. Call saveCurrentEdit to commit any changes.
- (AGSGraphic *) editGraphicFromMapViewDidClickAtPoint:(NSDictionary *)graphics;

// To create a new graphic, just call one of these methods. Call saveCurrentEdit to commit the new
// graphic and get a handle to it.
- (void) editNewPoint;
- (void) editNewMultipoint;
- (void) editNewLine;
- (void) editNewPolygon;

// saveCurrentGraphic will commit the current geometry edits. The returned graphic is the graphic
// that was edited. If this is an existing graphic, the object will be the same as returned
// by editGraphicFromDidClickAtPointEvent
- (AGSGraphic *) saveCurrentEdit;

// Cancel the current edit, if any.
- (void) cancelCurrentEdit;

// Convenience functions to provide feedback to the user while an edit is in progress. Use the standard
// iOS undo/redo functionality of the NSUndoManager. Listen to NSUndoManagerDidCloseUndoGroupNotification,
// NSUndoManagerDidUndoChangeNotification and NSUndoManagerDidRedoChangeNotification to determine when to
// read it's canUndo and canRedo properties to update the UI appropriately.
- (NSUndoManager *) getUndoManagerForGraphicsEdits;
- (AGSGeometry *) getCurrentEditGeometry;
- (AGSGraphicsLayer *) getGraphicsLayer:(EDNLiteGraphicsLayerType)layerType;
@end
