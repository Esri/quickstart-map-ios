//
//  AGSMapView+Graphics.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSBasemapsNotifications.h"
#import "AGSMapView+EQSGraphics.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSPoint+GeneralUtilities.h"

#import "EQSGraphicCallout.h"

#import "EQSHelper.h"

#import <objc/runtime.h>

@implementation AGSMapView (EQSGraphics)
#define kEQSGraphics_GlobalCalloutKey @"EQSGraphicCalloutKey"

#define kEQSGraphicsLayerName_Point @"eqsPointGraphicsLayer"
#define kEQSGraphicsLayerName_Polyline @"eqsPolylineGraphicsLayer"
#define kEQSGraphicsLayerName_Polygon @"eqsPolygonGraphicsLayer"

#define kEQSGraphicTag @"esriQuickStartLib"
#define kEQSGraphicTagKey @"eqsCreatedBy"

#define kEQSGraphics_CurrentEditingGraphicKey @"EQSCurrentEditingGraphic"
#define kEQSGraphics_TemporaryDelegateKey @"EQSTempDelegate"

#define kEQSSketchGraphicsLayerName @"eqsSketchGraphicsLayer"

#pragma mark - Add Graphics Programatically
- (AGSGraphic *) addPointAtLat:(double)latitude lon:(double)longitude
{
    AGSPoint *pt = [AGSPoint pointFromLat:latitude lon:longitude];
    
	return [self addPoint:pt];
}

- (AGSGraphic *) addPoint:(AGSPoint *)point
{
    AGSGraphic *g = [self __eqsGraphics_GetDefaultGraphicForGeometry:[point getWebMercatorAuxSpherePoint]];
    
    [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:g];
    
    return g;
}

- (AGSGraphic *) addPointAtLat:(double)latitude lon:(double)longitude withSymbol:(AGSMarkerSymbol *)markerSymbol
{
    AGSPoint *pt = [AGSPoint pointFromLat:latitude lon:longitude];

    return [self addPoint:pt withSymbol:markerSymbol];
}

- (AGSGraphic *) addPoint:(AGSPoint *)point withSymbol:(AGSMarkerSymbol *)markerSymbol
{
    AGSGraphic *g = [self __eqsGraphics_GetDefaultGraphicForGeometry:[point getWebMercatorAuxSpherePoint]];
    g.symbol = markerSymbol;
    [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:g];
    return g;
}


- (AGSGraphic *) addLineFromPoints:(NSArray *) points
{
	NSAssert1(points.count > 1, @"Must provide at least 2 points!", points.count);

    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [line addPathToPolyline];

    for (AGSPoint *pt in points)
    {
        [line addPointToPath:[pt getWebMercatorAuxSpherePoint]];
    }

    AGSGraphic *g = [self __eqsGraphics_GetDefaultGraphicForGeometry:line];

    [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:g];

    return g;
}

- (AGSGraphic *) addPolygonFromPoints:(NSArray *) points
{
    NSAssert1(points.count > 2, @"Must provide at least 3 points for a polygon!", points.count);

    AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [poly addRingToPolygon];

    for (AGSPoint *pt in points)
    {
        [poly addPointToRing:[pt getWebMercatorAuxSpherePoint]];
    }

    AGSGraphic *g = [self __eqsGraphics_GetDefaultGraphicForGeometry:poly];

    [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:g];

    return g;
}

#pragma mark - Clear graphics from the map
- (void) clearGraphics:(EQSGraphicsLayerType)layerType
{
    AGSGraphicsLayer *gl = nil;
    if (layerType & EQSGraphicsLayerTypePoint)
    {
        gl = [self getGraphicsLayer:EQSGraphicsLayerTypePoint];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
    
    if (layerType & EQSGraphicsLayerTypePolyline)
    {
        gl = [self getGraphicsLayer:EQSGraphicsLayerTypePolyline];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
    
    if (layerType & EQSGraphicsLayerTypePolygon)
    {
        gl = [self getGraphicsLayer:EQSGraphicsLayerTypePolygon];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
}

- (void) clearGraphics
{
    [self clearGraphics:(EQSGraphicsLayerTypePoint + 
                         EQSGraphicsLayerTypePolyline +
                         EQSGraphicsLayerTypePolygon)];
}

#pragma mark - Add graphic
- (AGSGraphicsLayer *) addGraphic:(AGSGraphic *)graphic
{
    return [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:graphic];
}

- (AGSGraphicsLayer *) addGraphic:(AGSGraphic *)graphic withAttribute:(id)attribute withValue:(id)value
{
    AGSGraphicsLayer *targetLayer = [self __eqsGraphics_GetGraphicsLayerForGraphic:graphic];
    if (!graphic.attributes)
    {
        graphic.attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [graphic.attributes setObject:value forKey:attribute];
    [targetLayer addGraphic:graphic];
    [targetLayer dataChanged];
    return targetLayer;
}


#pragma mark - Remove graphic
- (AGSGraphicsLayer *) removeGraphic:(AGSGraphic *)graphic
{
    AGSGraphicsLayer *owningLayer = [self removeGraphicNoRefresh:graphic];
    if (owningLayer)
    {
        [owningLayer dataChanged];
    }
    
    return owningLayer;
}

- (AGSGraphicsLayer *) removeGraphicNoRefresh:(AGSGraphic *)graphic
{
	if (graphic)
	{
		if (graphic.layer)
		{
            AGSGraphicsLayer *owningLayer = graphic.layer;
			[graphic.layer removeGraphic:graphic];
            return owningLayer;
		}
	}
    return nil;
}

- (NSSet *) removeGraphicsMatchingCriteria:(BOOL (^)(AGSGraphic *graphic))checkBlock
{
    NSArray *layersToCheck = [NSArray arrayWithObjects:[self __eqsGraphics_PointGraphicsLayer],
                                                       [self __eqsGraphics_PolylineGraphicsLayer],
                                                       [self __eqsGraphics_PolygonGraphicsLayer], nil];
    
    // Get the graphics to remove from all layers
    NSMutableArray *graphicsToRemove = [NSMutableArray array];
    for (AGSGraphicsLayer *gl in layersToCheck) {
        for (AGSGraphic *g in gl.graphics) {
            if (checkBlock(g))
            {
                [graphicsToRemove addObject:g];
            }
        }
    }
    
    // Remove each graphic from its layer, and remember the set of layers affected
    NSMutableSet *layersToUpdate = [NSMutableSet set];
    for (AGSGraphic *g in graphicsToRemove) {
        [layersToUpdate addObject:g.layer];
        [self removeGraphicNoRefresh:g];
    }
    
    // Flag the affected layers for redraw
    for (AGSGraphicsLayer *gl in layersToUpdate)
    {
        [gl dataChanged];
    }
    
    return layersToUpdate;
}

- (NSSet *) removeGraphicsByAttribute:(id)attribute withValue:(id)value
{
    return [self removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *graphic) {
        id gVal = [graphic.attributes objectForKey:attribute];
        return [gVal isEqual:value];
    }];
}

#pragma mark - Edit graphic
- (void) editGraphic:(AGSGraphic *)graphic
{
	[self __eqsGraphics_EditGraphic:graphic];
}

#pragma mark - Edit graphic selected from the map
- (AGSGraphic *) editGraphicFromMapViewDidClickAtPoint:(NSDictionary *)graphics
{
    AGSGraphic *graphicToEdit = nil;
    
    for (NSString *layerName in graphics.allKeys)
    {
		NSLog(@"Layer: %@", layerName);
        if (layerName == kEQSGraphicsLayerName_Point ||
            layerName == kEQSGraphicsLayerName_Polyline ||
            layerName == kEQSGraphicsLayerName_Polygon)
        {
            NSArray *graphicsToEditFromLayer = [graphics objectForKey:layerName];
            if (graphicsToEditFromLayer.count > 0)
            {
				NSLog(@"Graphics to edit: %d", graphicsToEditFromLayer.count);
                graphicToEdit = [graphicsToEditFromLayer lastObject];
                break;
            }
        }
    }
	
	[self editGraphic:graphicToEdit];
    
    return graphicToEdit;
}

#pragma mark - Create and Edit new graphics
- (void) createAndEditNewPoint
{
    [self __eqsGraphics_EditGeometry:[[AGSMutablePoint alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) createAndEditNewMultipoint
{
    [self __eqsGraphics_EditGeometry:[[AGSMutableMultipoint alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) createAndEditNewLine
{
    [self __eqsGraphics_EditGeometry:[[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) createAndEditNewPolygon
{
    [self __eqsGraphics_EditGeometry:[[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

#pragma mark - Save edit/create
- (AGSGraphic *) saveGraphicEdit
{
    // Update the graphics geometry
    AGSGeometry *editedGeometry = [self __eqsGraphics_SketchGraphicsLayer].geometry;
    AGSGraphic *editedGraphic = nil;
    AGSGraphic *editingGraphic = [self __eqsGraphics_GetCurrentEditingGraphic];
    if (editingGraphic)
    {
        // Editing an existing graphic
        editingGraphic.geometry = editedGeometry;
        AGSGraphicsLayer *owningLayer = editingGraphic.layer;
        // Get the owning layer and refresh it.
        [owningLayer dataChanged];
        
        editedGraphic = editingGraphic;
    }
    else
    {
        // Creating a new graphic
        AGSGraphic *g = [self __eqsGraphics_GetDefaultGraphicForGeometry:editedGeometry];
        [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:g];
        
        // Set the info template delegate, creating the global instance if necessary
		EQSGraphicCallout *globalCalloutObject = objc_getAssociatedObject(self, kEQSGraphics_GlobalCalloutKey);
        if (!globalCalloutObject)
        {
            globalCalloutObject = [[EQSGraphicCallout alloc] init];
			objc_setAssociatedObject(self, kEQSGraphics_GlobalCalloutKey, globalCalloutObject, OBJC_ASSOCIATION_RETAIN);
        }
        g.infoTemplateDelegate = globalCalloutObject;
        
        editedGraphic = g;
    }
    
    // Set the UI interaction back to how it was before.
    [self __eqsGraphics_SketchGraphicsLayer].geometry = nil;
    [self __eqsGraphics_SetCurrentEditingGraphic:nil];
    self.touchDelegate = objc_getAssociatedObject(self, kEQSGraphics_TemporaryDelegateKey);
    objc_setAssociatedObject(self, kEQSGraphics_TemporaryDelegateKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    return editedGraphic;
    
    return nil;
}

#pragma mark - Cancel edit/create
- (AGSGraphic *) cancelGraphicEdit
{
    AGSGraphic *graphicToReturn = [self __eqsGraphics_GetCurrentEditingGraphic];
    
    // Set the UI interaction back to how it was before.
    [self __eqsGraphics_SketchGraphicsLayer].geometry = nil;
    [self __eqsGraphics_SetCurrentEditingGraphic:nil];
    
    self.touchDelegate = objc_getAssociatedObject(self, kEQSGraphics_TemporaryDelegateKey);
    objc_setAssociatedObject(self, kEQSGraphics_TemporaryDelegateKey, nil, OBJC_ASSOCIATION_ASSIGN);

    return graphicToReturn;
}

#pragma mark - Undo/Redo
- (void)undoGraphicEdit
{
    [[self getUndoManagerForGraphicsEdits] undo];
}

- (void)redoGraphicEdit
{
    [[self getUndoManagerForGraphicsEdits] redo];
}

- (NSUndoManager *) registerListener:(id)object ForEditGraphicUndoRedoNotificationsUsing:(SEL)handlerMethod
{
    [self stop:object ListeningForEditGraphicUndoRedoNotificationsOn:nil];
    
    NSUndoManager *um = [self getUndoManagerForGraphicsEdits];
    if (um)
    {
        [[NSNotificationCenter defaultCenter] addObserver:object
                                                 selector:handlerMethod
                                                     name:@"NSUndoManagerDidCloseUndoGroupNotification"
                                                   object:um];
        [[NSNotificationCenter defaultCenter] addObserver:object
                                                 selector:handlerMethod
                                                     name:@"NSUndoManagerDidUndoChangeNotification"
                                                   object:um];
        [[NSNotificationCenter defaultCenter] addObserver:object
                                                 selector:handlerMethod
                                                     name:@"NSUndoManagerDidRedoChangeNotification"
                                                   object:um];
    }
    return um;
}

- (void) stop:(id)listener ListeningForEditGraphicUndoRedoNotificationsOn:(NSUndoManager *)manager
{
    [[NSNotificationCenter defaultCenter] removeObserver:listener
                                                    name:@"NSUndoManagerDidCloseUndoGroupNotification"
                                                  object:manager];
    [[NSNotificationCenter defaultCenter] removeObserver:listener
                                                    name:@"NSUndoManagerDidUndoChangeNotification"
                                                  object:manager];
    [[NSNotificationCenter defaultCenter] removeObserver:listener
                                                    name:@"NSUndoManagerDidRedoChangeNotification"
                                                  object:manager];
}


#pragma mark - Accessors to useful objects for UI feedback during editing
- (NSUndoManager *) getUndoManagerForGraphicsEdits
{
    return [self __eqsGraphics_SketchGraphicsLayer].undoManager;
}

- (AGSGeometry *) getCurrentEditGeometry
{
    return [self __eqsGraphics_SketchGraphicsLayer].geometry;
}

- (AGSGraphic *) getCurrentEditGraphic
{
    return [self __eqsGraphics_GetCurrentEditingGraphic];
}

- (AGSGraphicsLayer *) getGraphicsLayer:(EQSGraphicsLayerType)layerType
{
    [self __eqsGraphics_EnsureInitialized];
    
    return [self __eqsGraphics_GetGraphicsLayer:layerType];
}

#pragma mark - Initialization (Internal)
- (void) __eqsGraphics_EnsureInitialized
{
    // Make sure the layers are all added to the map.
    [self __eqsGraphics_EnsureEQSGraphicsLayersArePresent];
}

- (void) __eqsGraphics_EnsureEQSGraphicsLayersArePresent
{
	if (![self getLayerForName:kEQSGraphicsLayerName_Polygon])
    {
        [self addMapLayer:[self __eqsGraphics_GetGraphicsLayerForGeometryType:AGSGeometryTypePolygon]
                 withName:kEQSGraphicsLayerName_Polygon];
    }
	
    if (![self getLayerForName:kEQSGraphicsLayerName_Polyline])
    {
        [self addMapLayer:[self __eqsGraphics_GetGraphicsLayerForGeometryType:AGSGeometryTypePolyline]
                 withName:kEQSGraphicsLayerName_Polyline];
    }
    
    if (![self getLayerForName:kEQSGraphicsLayerName_Point])
    {
        [self addMapLayer:[self __eqsGraphics_GetGraphicsLayerForGeometryType:AGSGeometryTypePoint]
                 withName:kEQSGraphicsLayerName_Point];
    }
}

#pragma mark - Editing (Internal)
- (void) __eqsGraphics_EditGraphic:(AGSGraphic *)graphicToEdit
{
    if (graphicToEdit)
    {
        [self __eqsGraphics_EditGeometry:graphicToEdit.geometry];
        [self __eqsGraphics_SetCurrentEditingGraphic:graphicToEdit];
    }
}

- (void) __eqsGraphics_SetCurrentEditingGraphic:(AGSGraphic *)graphic
{
    objc_setAssociatedObject([self __eqsGraphics_SketchGraphicsLayer], kEQSGraphics_CurrentEditingGraphicKey, graphic, OBJC_ASSOCIATION_RETAIN);
}

- (AGSGraphic *) __eqsGraphics_GetCurrentEditingGraphic
{
    return objc_getAssociatedObject([self __eqsGraphics_SketchGraphicsLayer], kEQSGraphics_CurrentEditingGraphicKey);
}

- (AGSSketchGraphicsLayer *) __eqsGraphics_SketchGraphicsLayer
{
    AGSSketchGraphicsLayer *sgl = objc_getAssociatedObject(self, kEQSSketchGraphicsLayerName);
    if (!sgl)
    {
        sgl = [AGSSketchGraphicsLayer graphicsLayer];
        objc_setAssociatedObject(self, kEQSSketchGraphicsLayerName, sgl, OBJC_ASSOCIATION_RETAIN);
    }
    return sgl;
}

- (void) __eqsGraphics_EditGeometry:(AGSGeometry *)geom
{
    [self __eqsGraphics_EnsureInitialized];
    
    if (geom)
    {
        // The layer should always be the topmost layer so, even if we've added it previously, let's
        // remove it now so we can add it to the top again.
        if (![self getLayerForName:kEQSSketchGraphicsLayerName])
        {
            [self removeMapLayerWithName:kEQSSketchGraphicsLayerName];
        }

        AGSSketchGraphicsLayer *sketchGraphicsLayer = [self __eqsGraphics_SketchGraphicsLayer];
        [self addMapLayer:sketchGraphicsLayer withName:kEQSSketchGraphicsLayerName];
        
        // Store the real touch delegate
        if (objc_getAssociatedObject(self, kEQSGraphics_TemporaryDelegateKey) == nil &&
            self.touchDelegate != sketchGraphicsLayer)
        {
            objc_setAssociatedObject(self, kEQSGraphics_TemporaryDelegateKey, self.touchDelegate, OBJC_ASSOCIATION_RETAIN);
        }
        
        // Set the sketch layer to be the touch delegate.
        self.touchDelegate = sketchGraphicsLayer;
        
        AGSGeometry *editGeom = nil;
        editGeom = [geom mutableCopy];
        sketchGraphicsLayer.geometry = editGeom;
    }
}

#pragma mark - Symbology (Internal)
- (AGSSymbol *) __eqsGraphics_GetDefaultSymbolForGeometry:(AGSGeometry *)geom
{
    // Return a symbol depending on the type of geometry that was passed in.
    AGSSymbol *symbol = nil;
    AGSGeometryType geomType = AGSGeometryTypeForGeometry(geom);
    
    switch (geomType) {
        case AGSGeometryTypeMultipoint:
        case AGSGeometryTypePoint:
            symbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
            break;
            
        case AGSGeometryTypePolyline:
            symbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2.0f];
            break;
            
        case AGSGeometryTypePolygon:
        case AGSGeometryTypeEnvelope:
            symbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor redColor] outlineColor:[UIColor blueColor]];
            break;
            
        default:
            NSLog(@"Unexpected geometry type: %d", geomType);
            break;
    }
    
    return symbol;
}

#pragma mark - Add Graphics (Internal)
- (AGSGraphic *) __eqsGraphics_GetDefaultGraphicForGeometry:(AGSGeometry *)geom
{  
    // Create a graphic with an appropriate symbol and attributes, given a geometry.
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:geom
                                             symbol:[self __eqsGraphics_GetDefaultSymbolForGeometry:geom]
                                         attributes:[NSMutableDictionary dictionaryWithObject:kEQSGraphicTag forKey:kEQSGraphicTagKey]
                               infoTemplateDelegate:nil];
    return g;
}

- (AGSGraphicsLayer *) __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:(AGSGraphic *)graphic
{
    [self __eqsGraphics_EnsureInitialized];
    
    // Figure out what type of geometry the graphic is, and add the graphic to the appropriate layer.
    if (graphic)
    {
        AGSGraphicsLayer *gLayer = [self __eqsGraphics_GetGraphicsLayerForGraphic:graphic];
        
        if (gLayer)
        {
            [gLayer addGraphic:graphic];
            [gLayer dataChanged];
        }
        
        return gLayer;
    }
    return nil;
}

#pragma mark - Graphics Layers (Internal)
- (AGSGraphicsLayer *)__eqsGraphics_GetGraphicsLayerForGraphic:(AGSGraphic *)graphic
{
    AGSGeometry *geom = graphic.geometry;
    AGSGeometryType geomType = AGSGeometryTypeForGeometry(geom);
    
    return [self __eqsGraphics_GetGraphicsLayerForGeometryType:geomType];
}

- (AGSGraphicsLayer *) __eqsGraphics_GetGraphicsLayerForGeometryType:(AGSGeometryType)geomType
{
    AGSGraphicsLayer *gLayer = nil;
    
    switch (geomType) {
        case AGSGeometryTypePoint:
        case AGSGeometryTypeMultipoint:
            gLayer = [self __eqsGraphics_GetGraphicsLayer:EQSGraphicsLayerTypePoint];
            break;
            
        case AGSGeometryTypePolyline:
            gLayer = [self __eqsGraphics_GetGraphicsLayer:EQSGraphicsLayerTypePolyline];
            break;
            
        case AGSGeometryTypePolygon:
        case AGSGeometryTypeEnvelope:
            gLayer = [self __eqsGraphics_GetGraphicsLayer:EQSGraphicsLayerTypePolygon];
            break;
            
        default:
            NSLog(@"Unexpected geometry type: %d", geomType);
            break;
    }
    
    return gLayer;
}

- (AGSGraphicsLayer *) __eqsGraphics_GetGraphicsLayer:(EQSGraphicsLayerType)layerType
{
    switch (layerType) {
        case EQSGraphicsLayerTypePoint:
            return [self __eqsGraphics_PointGraphicsLayer];
            
        case EQSGraphicsLayerTypePolyline:
            return [self __eqsGraphics_PolylineGraphicsLayer];
            
        case EQSGraphicsLayerTypePolygon:
            return [self __eqsGraphics_PolygonGraphicsLayer];
    }
    
    return nil;
}

- (AGSGraphicsLayer *) __eqsGraphics_PointGraphicsLayer
{
    AGSGraphicsLayer *gl = objc_getAssociatedObject(self, kEQSGraphicsLayerName_Point);
    if (!gl)
    {
        gl = [AGSGraphicsLayer graphicsLayer];
        objc_setAssociatedObject(self, kEQSGraphicsLayerName_Point, gl, OBJC_ASSOCIATION_RETAIN);
    }
    return gl;
}

- (AGSGraphicsLayer *) __eqsGraphics_PolylineGraphicsLayer
{
    AGSGraphicsLayer *gl = objc_getAssociatedObject(self, kEQSGraphicsLayerName_Polyline);
    if (!gl)
    {
        gl = [AGSGraphicsLayer graphicsLayer];
        objc_setAssociatedObject(self, kEQSGraphicsLayerName_Polyline, gl, OBJC_ASSOCIATION_RETAIN);
    }
    return gl;
}

- (AGSGraphicsLayer *) __eqsGraphics_PolygonGraphicsLayer
{
    AGSGraphicsLayer *gl = objc_getAssociatedObject(self, kEQSGraphicsLayerName_Polygon);
    if (!gl)
    {
        gl = [AGSGraphicsLayer graphicsLayer];
        objc_setAssociatedObject(self, kEQSGraphicsLayerName_Polygon, gl, OBJC_ASSOCIATION_RETAIN);
    }
    return gl;
}
@end