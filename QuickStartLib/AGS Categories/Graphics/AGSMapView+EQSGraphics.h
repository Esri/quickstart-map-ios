//
//  AGSMapView+Graphics.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "AGSGraphicsLayer+EQSGraphics.h"

typedef enum {
    EQSGraphicsLayerTypePoint = 1,
    EQSGraphicsLayerTypePolyline = 2,
    EQSGraphicsLayerTypePolygon = 4
} EQSGraphicsLayerType;


@interface AGSMapView (EQSGraphics)

#pragma mark - Add Graphics from Geometries
// Create graphics using sequences of lat/long coordinates and default symbols.
- (AGSGraphic *) addPointAtLat:(double)latitude lon:(double)longitude;
- (AGSGraphic *) addPoint:(AGSPoint *)point;
- (AGSGraphic *) addLineFromPoints:(NSArray *) points;
- (AGSGraphic *) addPolygonFromPoints:(NSArray *) points;

// Create graphics and specify a symbol
- (AGSGraphic *) addPointAtLat:(double)latitude lon:(double)longitude withSymbol:(AGSMarkerSymbol *)markerSymbol;
- (AGSGraphic *) addPoint:(AGSPoint *)point withSymbol:(AGSMarkerSymbol *)markerSymbol;

//TODO - (AGSGraphic *) addLine:(AGSPolyline *) line;
//TODO - (AGSGraphic *) addPolygon:(AGSPolygon *) polygon;




#pragma mark - Add Graphics
// Add an existing graphic to the map.
- (AGSGraphicsLayer *) addGraphic:(AGSGraphic *)graphic;
// Shortcut to populate the AGSGraphic.attributes dictionary with a key/value
// See also removeGraphicsByAttribute:withValue
- (AGSGraphicsLayer *) addGraphic:(AGSGraphic *)graphic withAttribute:(id)attribute withValue:(id)value;




#pragma mark - Remove Graphics
// Remove individual graphic
- (AGSGraphicsLayer *) removeGraphic:(AGSGraphic *)graphic;

//TODO - Improve the return values. Should include layers and graphics.
// Remove graphics by matching some criteria. The NSSet will contain AGSGraphicsLayers that were updated.
- (NSSet *) removeGraphicsMatchingCriteria:(BOOL(^)(AGSGraphic *graphic))checkBlock;
// See also addGraphic:withAttribute:withValue
- (NSSet *) removeGraphicsByAttribute:(id)attribute withValue:(id)value;

// Clear graphics from the map. Optionally specify what type or types of graphics to clear.
- (void) clearGraphics:(EQSGraphicsLayerType)layerType;
- (void) clearGraphics;




#pragma mark - Creating new graphics
// To create and start editing a new graphic, just call one of these methods. Call saveCurrentEdit to
// commit the new graphic and get a handle to it. Note, until a geometry is saved, it doesn't become a
// graphic, hence these functions all return VOID.
- (void) createAndEditNewPoint;
- (void) createAndEditNewMultipoint;
- (void) createAndEditNewLine;
- (void) createAndEditNewPolygon;


#pragma mark - Editing existing graphics
// Start editing an existing graphic/shape
- (void) editGraphic:(AGSGraphic *)graphic;

// Call this from the mapView:DidClickAtPoint:mapPoint:graphics handler of AGSMapViewTouchDelegate
// to automatically work out which existing graphic to edit and start editing it. The selected graphic will
// be returned, and the geometry put into an edit state. Call saveCurrentEdit to commit any changes.
// This relies on the mapView:DidClickAtPoint:mapPoint:graphics to have already pared down the graphics
// around the hit point in the UI.
- (AGSGraphic *) editGraphicFromMapViewDidClickAtPoint:(NSDictionary *)graphics;


#pragma mark - Finishing an edit
// saveCurrentEdit will commit the current geometry edits. The returned graphic is the graphic
// that was edited. If this is an existing graphic, the object will be the same as returned
// by editGraphicFromDidClickAtPointEvent
- (AGSGraphic *) saveGraphicEdit;

// Cancel the current edit, if any. If this was an Edit rather than a Create, the unmodified graphic is returned.
- (AGSGraphic *) cancelGraphicEdit;




#pragma mark - Undo/Redo during an edit
// Undo and redo - call these when you want to undo/redo something.
// See also registerListener:ForEditGraphicUndoRedoNotificationsUsing: to be notified that an undo or redo
// has happened so you can check the state of the NSUndoManager and update the UI appropriately.
- (void) undoGraphicEdit;
- (void) redoGraphicEdit;

// Undo/Redo registration
// Use these helper methods to register yourself as interested in knowing when the undo/redo stack has changed.
// Pass in an object and selector for a method of that object that takes a single NSNotification parameter.
// When that method is called, check the canUndo and canRedo state of the NSUndoManager (which you can get
// using the getUndoManagerForGraphicsEdits) to update your UI.
- (NSUndoManager *) registerListener:(id)object ForEditGraphicUndoRedoNotificationsUsing:(SEL)handlerMethod;
// To stop listening to all NSUndoManagers, just pass in nil for the manager.
- (void) stop:(id)listener ListeningForEditGraphicUndoRedoNotificationsOn:(NSUndoManager *)manager;
// Get a handle on the NSUndoManager (returned from registerListener:ForEditGraphicUndoRedoNotificationsUsing:)
// in case you don't want to hold on to it yourself. And why would you?
- (NSUndoManager *) getUndoManagerForGraphicsEdits;




#pragma mark - Convenience functions for UI feedback
// Convenience functions to provide feedback to the user while an edit is in progress. Use the standard
// iOS undo/redo functionality of the NSUndoManager. Listen to NSUndoManagerDidCloseUndoGroupNotification,
// NSUndoManagerDidUndoChangeNotification and NSUndoManagerDidRedoChangeNotification to determine when to
// read it's canUndo and canRedo properties to update the UI appropriately.
- (AGSGeometry *) getCurrentEditGeometry;
- (AGSGraphic *) getCurrentEditGraphic;
- (AGSGraphicsLayer *) getGraphicsLayer:(EQSGraphicsLayerType)layerType;
@end