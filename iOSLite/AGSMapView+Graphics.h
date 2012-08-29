//
//  AGSMapView+Graphics.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (EQSGraphics)

typedef enum {
    EQSGraphicsLayerTypePoint = 1,
    EQSGraphicsLayerTypePolyline = 2,
    EQSGraphicsLayerTypePolygon = 4
} EQSGraphicsLayerType;




#pragma mark - Add and Remove Graphics
// ADD & REMOVE Graphics

// Create graphics using sequences of lat/long coordinates.
- (AGSGraphic *) addPointAtLat:(double)latitude lon:(double)longitude;
- (AGSGraphic *) addPoint:(AGSPoint *)point;
- (AGSGraphic *) addLineFromPoints:(NSArray *) points;
- (AGSGraphic *) addPolygonFromPoints:(NSArray *) points;

- (AGSGraphic *) addPointAtLat:(double)latitude lon:(double)longitude withSymbol:(AGSMarkerSymbol *)markerSymbol;
- (AGSGraphic *) addPoint:(AGSPoint *)point withSymbol:(AGSMarkerSymbol *)markerSymbol;

//TODO - (AGSGraphic *) addLine:(AGSPolyline *) line;
//TODO - (AGSGraphic *) addPolygon:(AGSPolygon *) polygon;

- (AGSGraphicsLayer *) addGraphic:(AGSGraphic *)graphic;
// Shortcut to populate the AGSGraphic.attributes dictionary with a key/value
// See also removeGraphicsByAttribute:withValue
- (AGSGraphicsLayer *) addGraphic:(AGSGraphic *)graphic withAttribute:(id)attribute withValue:(id)value;

// Remove individual graphic
- (AGSGraphicsLayer *) removeGraphic:(AGSGraphic *)graphic;

// Remove graphics by matching some criteria. The NSSet will contain AGSGraphicsLayers that were updated.
- (NSSet *) removeGraphicsMatchingCriteria:(BOOL(^)(AGSGraphic *graphic))checkBlock;
// See also addGraphic:withAttribute:withValue
- (NSSet *) removeGraphicsByAttribute:(id)attribute withValue:(id)value;

#pragma mark - Clear graphics
// Clear graphics from the map. Optionally specify what type or types of graphics to clear.
- (void) clearGraphics:(EQSGraphicsLayerType)layerType;
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

// Cancel the current edit, if any. If this was an Edit rather than a Create, the unmodified graphic is returned.
- (AGSGraphic *) cancelCurrentEdit;




#pragma mark - Convenience functions for UI feedback
// Convenience functions to provide feedback to the user while an edit is in progress. Use the standard
// iOS undo/redo functionality of the NSUndoManager. Listen to NSUndoManagerDidCloseUndoGroupNotification,
// NSUndoManagerDidUndoChangeNotification and NSUndoManagerDidRedoChangeNotification to determine when to
// read it's canUndo and canRedo properties to update the UI appropriately.
- (NSUndoManager *) getUndoManagerForGraphicsEdits;
- (AGSGeometry *) getCurrentEditGeometry;
- (AGSGraphic *) getCurrentEditGraphic;
- (AGSGraphicsLayer *) getGraphicsLayer:(EQSGraphicsLayerType)layerType;

@end
