//
//  AGSMapView+Graphics.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Graphics.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Basemaps.h"
#import "STXHelper.h"

@implementation AGSMapView (Graphics)
AGSGraphicsLayer * __stxPointGraphicsLayer = nil;
AGSGraphicsLayer * __stxPolylineGraphicsLayer = nil;
AGSGraphicsLayer * __stxPolygonGraphicsLayer = nil;
AGSSketchGraphicsLayer * __stxSketchGraphicsLayer = nil;
id<AGSMapViewTouchDelegate> __stxTempTouchDelegate = nil;

AGSGraphic * __stxCurrentEditingGraphic = nil;

#define kSTXGraphicsLayerName_Point @"stxPointGraphicsLayer"
#define kSTXGraphicsLayerName_Polyline @"stxPolylineGraphicsLayer"
#define kSTXGraphicsLayerName_Polygon @"stxPolygonGraphicsLayer"

#define kSTXGraphicTag @"iOSLiteAPI"
#define kSTXGraphicTagKey @"createdBy"

#define kSTXSketchGraphicsLayerName @"stxSketchGraphcisLayer"

#pragma mark - Add Graphics Programatically
- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude
{
    AGSPoint *pt = [STXHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
	return [self addPoint:pt];
}

- (AGSGraphic *) addPoint:(AGSPoint *)point
{    
    AGSGraphic *g = [self __stxGetDefaultGraphicForGeometry:point];
    
    [self __stxAddGraphicToAppropriateGraphicsLayer:g];
    
    return g;
}

- (AGSGraphic *) addLineFromPoints:(NSArray *) points
{
	NSAssert1(points.count > 1, @"Must provide at least 2 points!", points.count);

    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [line addPathToPolyline];

    for (AGSPoint *pt in points)
    {
        [line addPointToPath:pt];
    }

    AGSGraphic *g = [self __stxGetDefaultGraphicForGeometry:line];

    [self __stxAddGraphicToAppropriateGraphicsLayer:g];

    return g;
}

- (AGSGraphic *) addPolygonFromPoints:(NSArray *) points
{
    NSAssert1(points.count > 2, @"Must provide at least 3 points for a polygon!", points.count);

    AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [poly addRingToPolygon];

    for (AGSPoint *pt in points)
    {
        [poly addPointToRing:pt];
    }

    AGSGraphic *g = [self __stxGetDefaultGraphicForGeometry:poly];

    [self __stxAddGraphicToAppropriateGraphicsLayer:g];

    return g;
}

#pragma mark - Clear graphics from the map
- (void) clearGraphics:(STXGraphicsLayerType)layerType
{
    AGSGraphicsLayer *gl = nil;
    if (layerType & STXGraphicsLayerTypePoint)
    {
        gl = [self getGraphicsLayer:STXGraphicsLayerTypePoint];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
    
    if (layerType & STXGraphicsLayerTypePolyline)
    {
        gl = [self getGraphicsLayer:STXGraphicsLayerTypePolyline];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
    
    if (layerType & STXGraphicsLayerTypePolygon)
    {
        gl = [self getGraphicsLayer:STXGraphicsLayerTypePolygon];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
}

- (void) clearGraphics
{
    [self clearGraphics:(STXGraphicsLayerTypePoint + 
                         STXGraphicsLayerTypePolyline +
                         STXGraphicsLayerTypePolygon)];
}

#pragma marl - Remove graphic
- (void) removeGraphic:(AGSGraphic *)graphic
{
	if (graphic)
	{
		if (graphic.layer)
		{
			[graphic.layer removeGraphic:graphic];
		}
	}
}

- (void) removeGraphicsMatchingCriteria:(BOOL (^)(AGSGraphic *))checkBlock
{
    NSArray *layersToCheck = [NSArray arrayWithObjects:__stxPointGraphicsLayer,
                                                       __stxPolylineGraphicsLayer, 
                                                       __stxPolygonGraphicsLayer, nil];
    
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
        [self removeGraphic:g];
    }
    
    // Flag the affected layers for redraw
    for (AGSGraphicsLayer *gl in layersToUpdate)
    {
        [gl dataChanged];
    }
}

#pragma mark - Edit graphic
- (void) editGraphic:(AGSGraphic *)graphic
{
	[self __stxEditGraphic:graphic];
}

#pragma mark - Edit graphic selected from the map
- (AGSGraphic *) editGraphicFromMapViewDidClickAtPoint:(NSDictionary *)graphics
{
    AGSGraphic *graphicToEdit = nil;
    
    for (NSString *layerName in graphics.allKeys)
    {
        if (layerName == kSTXGraphicsLayerName_Point ||
            layerName == kSTXGraphicsLayerName_Polyline ||
            layerName == kSTXGraphicsLayerName_Polygon)
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
    [self __stxEditGeometry:[[AGSMutablePoint alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) createAndEditNewMultipoint
{
    [self __stxEditGeometry:[[AGSMutableMultipoint alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) createAndEditNewLine
{
    [self __stxEditGeometry:[[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) createAndEditNewPolygon
{
    [self __stxEditGeometry:[[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

#pragma mark - Save edit/create
- (AGSGraphic *) saveCurrentEdit
{
    if (__stxSketchGraphicsLayer)
    {
        // Update the graphics geometry
        AGSGeometry *editedGeometry = __stxSketchGraphicsLayer.geometry;
        AGSGraphic *editedGraphic = nil;
        if (__stxCurrentEditingGraphic)
        {
            // Editing an existing graphic
            __stxCurrentEditingGraphic.geometry = editedGeometry;
            AGSGraphicsLayer *owningLayer = __stxCurrentEditingGraphic.layer;
            // Get the owning layer and refresh it.
            [owningLayer dataChanged];
            
            editedGraphic = __stxCurrentEditingGraphic;
        }
        else
        {
            // Creating a new graphic
            AGSGraphic *g = [self __stxGetDefaultGraphicForGeometry:editedGeometry];
            [self __stxAddGraphicToAppropriateGraphicsLayer:g];
            
            editedGraphic = g;
        }
        
        // Set the UI interaction back to how it was before.
        __stxSketchGraphicsLayer.geometry = nil;
        __stxCurrentEditingGraphic = nil;
        self.touchDelegate = __stxTempTouchDelegate;
        __stxTempTouchDelegate = nil;
        
        return editedGraphic;
    }
    
    return nil;
}

#pragma mark - Cancel edit/create
- (void) cancelCurrentEdit
{
    if (__stxSketchGraphicsLayer)
    {
        // Set the UI interaction back to how it was before.
        __stxSketchGraphicsLayer.geometry = nil;
        __stxCurrentEditingGraphic = nil;
        self.touchDelegate = __stxTempTouchDelegate;
        __stxTempTouchDelegate = nil;
    }
}

#pragma mark - Accessors to useful objects for UI feedback during editing
- (NSUndoManager *) getUndoManagerForGraphicsEdits
{
    if (__stxSketchGraphicsLayer)
    {
        return __stxSketchGraphicsLayer.undoManager;
    }
    return nil;
}

- (AGSGeometry *) getCurrentEditGeometry
{
    if (__stxSketchGraphicsLayer)
    {
        return __stxSketchGraphicsLayer.geometry;
    }
    return nil;
}

- (AGSGraphicsLayer *) getGraphicsLayer:(STXGraphicsLayerType)layerType
{
    if (!__stxPointGraphicsLayer)
    {
        // Create three graphics layers and add them to the map.
        __stxPointGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        __stxPolylineGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        __stxPolygonGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(__stxGraphicsBasemapDidChange:) 
                                                     name:kSTXNotification_BasemapDidChange
                                                   object:self];
        
    }
    
    [self __ensureSTXGraphicsLayersAdded];
    
    switch (layerType) {
        case STXGraphicsLayerTypePoint:
            return __stxPointGraphicsLayer;
            
        case STXGraphicsLayerTypePolyline:
            return __stxPolylineGraphicsLayer;
            
        case STXGraphicsLayerTypePolygon:
            return __stxPolygonGraphicsLayer;
    }
    
    return nil;
}

#pragma mark - Internal/Private

- (void) __stxEditGraphic:(AGSGraphic *)graphicToEdit
{
    if (graphicToEdit)
    {
        [self __stxEditGeometry:graphicToEdit.geometry];
        __stxCurrentEditingGraphic = graphicToEdit;
    }
}

- (void) __stxEditGeometry:(AGSGeometry *)geom
{
    if (geom)
    {
        if (!__stxSketchGraphicsLayer)
        {
            __stxSketchGraphicsLayer = [AGSSketchGraphicsLayer graphicsLayer];
        }
        
        // The layer should always be the topmost layer so, even if we've added it previously, let's
        // remove it now so we can add it to the top again.
        if (![self getLayerForName:kSTXSketchGraphicsLayerName])
        {
            [self removeMapLayerWithName:kSTXSketchGraphicsLayerName];
        }

        [self addMapLayer:__stxSketchGraphicsLayer withName:kSTXSketchGraphicsLayerName];
        
        // Store the real touch delegate
        if (!__stxTempTouchDelegate &&
            self.touchDelegate != __stxSketchGraphicsLayer)
        {
            __stxTempTouchDelegate = self.touchDelegate;
        }
        
        // Set the sketch layer to be the touch delegate.
        self.touchDelegate = __stxSketchGraphicsLayer;
        
        AGSGeometry *editGeom = nil;
        editGeom = [geom mutableCopy];
        __stxSketchGraphicsLayer.geometry = editGeom;
    }
}

- (void) __ensureSTXGraphicsLayersAdded
{
	if (![self getLayerForName:kSTXGraphicsLayerName_Polygon])
    {
        [self addMapLayer:__stxPolygonGraphicsLayer withName:kSTXGraphicsLayerName_Polygon];
    }
	
    if (![self getLayerForName:kSTXGraphicsLayerName_Polyline])
    {
        [self addMapLayer:__stxPolylineGraphicsLayer withName:kSTXGraphicsLayerName_Polyline];
    }
    
    if (![self getLayerForName:kSTXGraphicsLayerName_Point])
    {
        [self addMapLayer:__stxPointGraphicsLayer withName:kSTXGraphicsLayerName_Point];
    }
}

- (void) __initSTXGraphics
{
    // Asking for any layer will ensure they're all created and added.
    [self getGraphicsLayer:STXGraphicsLayerTypePoint];
}

- (void) __stxGraphicsBasemapDidChange:(NSNotification *)notification
{
	[self __ensureSTXGraphicsLayersAdded];
}

- (AGSSymbol *) __stxGetDefaultSymbolForGeometry:(AGSGeometry *)geom
{
    // Return a symbol depending on the type of geometry that was passed in.
    AGSSymbol *symbol = nil;
    if ([geom isKindOfClass:[AGSPoint class]] ||
        [geom isKindOfClass:[AGSMultipoint class]])
    {
        symbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
    }
    else if ([geom isKindOfClass:[AGSPolyline class]])
    {
        symbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2.0f];        
    }
    else if ([geom isKindOfClass:[AGSPolygon class]])
    {
        symbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor redColor] outlineColor:[UIColor blueColor]];
    }
    else {
        NSLog(@"Unrecognized Geometry Class: %@", geom);
    }
    return symbol;
}

- (AGSGraphic *) __stxGetDefaultGraphicForGeometry:(AGSGeometry *)geom
{  
    // Create a graphic with an appropriate symbol and attributes, given a geometry.
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:geom
                                             symbol:[self __stxGetDefaultSymbolForGeometry:geom]
                                         attributes:[NSMutableDictionary dictionaryWithObject:kSTXGraphicTag forKey:kSTXGraphicTagKey]
                               infoTemplateDelegate:nil];
    return g;
}

- (void) __stxAddGraphicToAppropriateGraphicsLayer:(AGSGraphic *)graphic
{
    // Figure out what type of geometry the graphic is, and add the graphic to the appropriate layer.
    if (graphic)
    {
        AGSGeometry *geom = graphic.geometry;
        AGSGraphicsLayer *gLayer = nil;
        if ([geom isKindOfClass:[AGSPoint class]] ||
            [geom isKindOfClass:[AGSMultipoint class]])
        {
            gLayer = [self getGraphicsLayer:STXGraphicsLayerTypePoint];
        }
        else if ([geom isKindOfClass:[AGSPolyline class]])
        {
            gLayer = [self getGraphicsLayer:STXGraphicsLayerTypePolyline];
        }
        else if ([geom isKindOfClass:[AGSPolygon class]])
        {
            gLayer = [self getGraphicsLayer:STXGraphicsLayerTypePolygon];
        }
        else {
            NSLog(@"Unrecognized Geometry Class: %@", geom);
        }
        
        if (gLayer)
        {
            [gLayer addGraphic:graphic];
            [gLayer dataChanged];
        }
    }
}

- (NSArray *) __stxGetArrayFromArguments:(NSNumber *)first arguments:(va_list)otherArgs
{
    // Just a helper function.
    NSMutableArray *result = [NSMutableArray array];
    for (NSNumber *nextNumber = first; nextNumber != nil; nextNumber = va_arg(otherArgs, NSNumber *))
    {
        [result addObject:nextNumber];
    }

    return result;
}
@end
