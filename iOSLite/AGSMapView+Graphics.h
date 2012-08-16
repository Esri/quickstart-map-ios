//
//  AGSMapView+Graphics.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Graphics)

typedef enum {
    STXGraphicsLayerTypePoint = 1,
    STXGraphicsLayerTypePolyline = 2,
    STXGraphicsLayerTypePolygon = 4
} STXGraphicsLayerType;




#pragma mark - Add and Remove Graphics
// ADD & REMOVE Graphics

// Create graphics using sequences of lat/long coordinates.
- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude;
- (AGSGraphic *) addPoint:(AGSPoint *)point;
- (AGSGraphic *) addLineFromPoints:(NSArray *) points;
- (AGSGraphic *) addPolygonFromPoints:(NSArray *) points;

// Remove individual graphics
- (void) removeGraphic:(AGSGraphic *)graphic;
- (void) removeGraphicsMatchingCriteria:(BOOL(^)(AGSGraphic *))checkBlock;




#pragma mark - Clear graphics
// Clear graphics from the map. Optionally specify what type or types of graphics to clear.
- (void) clearGraphics:(STXGraphicsLayerType)layerType;
- (void) clearGraphics;




#pragma mark - Create and Edit Graphics
// CREATE & EDIT Graphics

// To create and start editing a new graphic, just call one of these methods. Call saveCurrentEdit to
// commit the new graphic and get a handle to it. Note, until a geometry is saved, it doesn't become a
// graphic, hence these functions all return VOID.
- (void) createAndEditNewPoint;
- (void) createAndEditNewMultipoint;
- (void) createAndEditNewLine;
- (void) createAndEditNewPolygon;

// Start editing an existing graphic/shape
- (void) editGraphic:(AGSGraphic *)graphic;

// Call this from the mapView:DidClickAtPoint:mapPoint:graphics handler of AGSMapViewTouchDelegate
// to automatically work out which existing graphic to edit and start editing it. The selected graphic will
// be returned, and the geometry put into an edit state. Call saveCurrentEdit to commit any changes.
// This relies on the mapView:DidClickAtPoint:mapPoint:graphics to have already pared down the graphics
// around the hit point in the UI.
- (AGSGraphic *) editGraphicFromMapViewDidClickAtPoint:(NSDictionary *)graphics;

// saveCurrentEdit will commit the current geometry edits. The returned graphic is the graphic
// that was edited. If this is an existing graphic, the object will be the same as returned
// by editGraphicFromDidClickAtPointEvent
- (AGSGraphic *) saveCurrentEdit;

// Cancel the current edit, if any.
- (void) cancelCurrentEdit;




#pragma mark - Convenience functions for UI feedback
// Convenience functions to provide feedback to the user while an edit is in progress. Use the standard
// iOS undo/redo functionality of the NSUndoManager. Listen to NSUndoManagerDidCloseUndoGroupNotification,
// NSUndoManagerDidUndoChangeNotification and NSUndoManagerDidRedoChangeNotification to determine when to
// read it's canUndo and canRedo properties to update the UI appropriately.
- (NSUndoManager *) getUndoManagerForGraphicsEdits;
- (AGSGeometry *) getCurrentEditGeometry;
- (AGSGraphicsLayer *) getGraphicsLayer:(STXGraphicsLayerType)layerType;

@end
