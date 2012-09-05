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

@implementation AGSMapView (EQSGraphics)
AGSGraphicsLayer * __eqsPointGraphicsLayer = nil;
AGSGraphicsLayer * __eqsPolylineGraphicsLayer = nil;
AGSGraphicsLayer * __eqsPolygonGraphicsLayer = nil;
AGSSketchGraphicsLayer * __eqsSketchGraphicsLayer = nil;
id<AGSMapViewTouchDelegate> __eqsTempTouchDelegate = nil;

AGSGraphic * __eqsCurrentEditingGraphic = nil;

EQSGraphicCallout *__eqsTheGraphicCallout = nil;

#define kEQSGraphicsLayerName_Point @"eqsPointGraphicsLayer"
#define kEQSGraphicsLayerName_Polyline @"eqsPolylineGraphicsLayer"
#define kEQSGraphicsLayerName_Polygon @"eqsPolygonGraphicsLayer"

#define kEQSGraphicTag @"esriQuickStartLib"
#define kEQSGraphicTagKey @"eqsCreatedBy"

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
    NSArray *layersToCheck = [NSArray arrayWithObjects:__eqsPointGraphicsLayer,
                                                       __eqsPolylineGraphicsLayer, 
                                                       __eqsPolygonGraphicsLayer, nil];
    
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
        return [[graphic.attributes objectForKey:attribute] isEqual:value];
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
        if (layerName == kEQSGraphicsLayerName_Point ||
            layerName == kEQSGraphicsLayerName_Polyline ||
            layerName == kEQSGraphicsLayerName_Polygon)
        {
            NSArray *graphicsToEditFromLayer = [graphics objectForKey:layerName];
            if (graphicsToEditFromLayer.count > 0)
            {
                graphicToEdit = [graphicsToEditFromLayer objectAtIndex:0];
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
    if (__eqsSketchGraphicsLayer)
    {
        // Update the graphics geometry
        AGSGeometry *editedGeometry = __eqsSketchGraphicsLayer.geometry;
        AGSGraphic *editedGraphic = nil;
        if (__eqsCurrentEditingGraphic)
        {
            // Editing an existing graphic
            __eqsCurrentEditingGraphic.geometry = editedGeometry;
            AGSGraphicsLayer *owningLayer = __eqsCurrentEditingGraphic.layer;
            // Get the owning layer and refresh it.
            [owningLayer dataChanged];
            
            editedGraphic = __eqsCurrentEditingGraphic;
        }
        else
        {
            // Creating a new graphic
            AGSGraphic *g = [self __eqsGraphics_GetDefaultGraphicForGeometry:editedGeometry];
            [self __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:g];

            // Set the info template delegate
            if (!__eqsTheGraphicCallout)
            {
                __eqsTheGraphicCallout = [[EQSGraphicCallout alloc] init];
            }
            g.infoTemplateDelegate = __eqsTheGraphicCallout;
            
            editedGraphic = g;
        }
        
        // Set the UI interaction back to how it was before.
        __eqsSketchGraphicsLayer.geometry = nil;
        __eqsCurrentEditingGraphic = nil;
        self.touchDelegate = __eqsTempTouchDelegate;
        __eqsTempTouchDelegate = nil;
        
        return editedGraphic;
    }
    
    return nil;
}

#pragma mark - Cancel edit/create
- (AGSGraphic *) cancelGraphicEdit
{
    if (__eqsSketchGraphicsLayer)
    {
        AGSGraphic *graphicToReturn = __eqsCurrentEditingGraphic;
        // Set the UI interaction back to how it was before.
        __eqsSketchGraphicsLayer.geometry = nil;
        __eqsCurrentEditingGraphic = nil;
        self.touchDelegate = __eqsTempTouchDelegate;
        __eqsTempTouchDelegate = nil;
        return graphicToReturn;
    }
    
    return nil;
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
    if (__eqsSketchGraphicsLayer)
    {
        return __eqsSketchGraphicsLayer.undoManager;
    }
    return nil;
}

- (AGSGeometry *) getCurrentEditGeometry
{
    if (__eqsSketchGraphicsLayer)
    {
        return __eqsSketchGraphicsLayer.geometry;
    }
    return nil;
}

- (AGSGraphic *) getCurrentEditGraphic
{
    return __eqsCurrentEditingGraphic;
}

- (AGSGraphicsLayer *) getGraphicsLayer:(EQSGraphicsLayerType)layerType
{
    [self __eqsGraphics_EnsureInitialized];
    
    switch (layerType) {
        case EQSGraphicsLayerTypePoint:
            return __eqsPointGraphicsLayer;
            
        case EQSGraphicsLayerTypePolyline:
            return __eqsPolylineGraphicsLayer;
            
        case EQSGraphicsLayerTypePolygon:
            return __eqsPolygonGraphicsLayer;
    }
    
    return nil;
}

#pragma mark - Internal/Private

- (void) __eqsGraphics_EnsureInitialized
{
    // Create three graphics layers if necessary.
    if (!__eqsPointGraphicsLayer)
    {
        __eqsPointGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    }
    if (!__eqsPolylineGraphicsLayer)
    {
        __eqsPolylineGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    }
    if (!__eqsPolygonGraphicsLayer)
    {
        __eqsPolygonGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    }

    // Make sure they're added to the map.
    [self __eqsGraphics_EnsureEQSGraphicsLayersArePresent];
}

- (void) __eqsGraphics_EnsureEQSGraphicsLayersArePresent
{
	if (![self getLayerForName:kEQSGraphicsLayerName_Polygon])
    {
        [self addMapLayer:__eqsPolygonGraphicsLayer withName:kEQSGraphicsLayerName_Polygon];
    }
	
    if (![self getLayerForName:kEQSGraphicsLayerName_Polyline])
    {
        [self addMapLayer:__eqsPolylineGraphicsLayer withName:kEQSGraphicsLayerName_Polyline];
    }
    
    if (![self getLayerForName:kEQSGraphicsLayerName_Point])
    {
        [self addMapLayer:__eqsPointGraphicsLayer withName:kEQSGraphicsLayerName_Point];
    }
}

- (void) __eqsGraphics_EditGraphic:(AGSGraphic *)graphicToEdit
{
    if (graphicToEdit)
    {
        [self __eqsGraphics_EditGeometry:graphicToEdit.geometry];
        __eqsCurrentEditingGraphic = graphicToEdit;
    }
}

- (void) __eqsGraphics_EditGeometry:(AGSGeometry *)geom
{
    if (geom)
    {
        if (!__eqsSketchGraphicsLayer)
        {
            __eqsSketchGraphicsLayer = [AGSSketchGraphicsLayer graphicsLayer];
        }
        
        // The layer should always be the topmost layer so, even if we've added it previously, let's
        // remove it now so we can add it to the top again.
        if (![self getLayerForName:kEQSSketchGraphicsLayerName])
        {
            [self removeMapLayerWithName:kEQSSketchGraphicsLayerName];
        }

        [self addMapLayer:__eqsSketchGraphicsLayer withName:kEQSSketchGraphicsLayerName];
        
        // Store the real touch delegate
        if (!__eqsTempTouchDelegate &&
            self.touchDelegate != __eqsSketchGraphicsLayer)
        {
            __eqsTempTouchDelegate = self.touchDelegate;
        }
        
        // Set the sketch layer to be the touch delegate.
        self.touchDelegate = __eqsSketchGraphicsLayer;
        
        AGSGeometry *editGeom = nil;
        editGeom = [geom mutableCopy];
        __eqsSketchGraphicsLayer.geometry = editGeom;
    }
}

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

- (AGSGraphic *) __eqsGraphics_GetDefaultGraphicForGeometry:(AGSGeometry *)geom
{  
    // Create a graphic with an appropriate symbol and attributes, given a geometry.
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:geom
                                             symbol:[self __eqsGraphics_GetDefaultSymbolForGeometry:geom]
                                         attributes:[NSMutableDictionary dictionaryWithObject:kEQSGraphicTag forKey:kEQSGraphicTagKey]
                               infoTemplateDelegate:nil];
    return g;
}

- (AGSGraphicsLayer *)__eqsGraphics_GetGraphicsLayerForGraphic:(AGSGraphic *)graphic
{
    AGSGeometry *geom = graphic.geometry;
    AGSGraphicsLayer *gLayer = nil;

    AGSGeometryType geomType = AGSGeometryTypeForGeometry(geom);
    
    switch (geomType) {
        case AGSGeometryTypePoint:
        case AGSGeometryTypeMultipoint:
            gLayer = [self getGraphicsLayer:EQSGraphicsLayerTypePoint];
            break;
            
        case AGSGeometryTypePolyline:
            gLayer = [self getGraphicsLayer:EQSGraphicsLayerTypePolyline];
            break;

        case AGSGeometryTypePolygon:
        case AGSGeometryTypeEnvelope:
            gLayer = [self getGraphicsLayer:EQSGraphicsLayerTypePolygon];
            break;
            
        default:
            NSLog(@"Unexpected geometry type: %d", geomType);
            break;
    }
    
    return gLayer;
}

- (AGSGraphicsLayer *) __eqsGraphics_AddGraphicToAppropriateGraphicsLayer:(AGSGraphic *)graphic
{
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
@end
