//
//  AGSMapView+Graphics.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Graphics.h"
#import "AGSMapView+GeneralUtilities.h"
#import "EDNLiteHelper.h"

@implementation AGSMapView (Graphics)
AGSGraphicsLayer * __ednLitePointGraphicsLayer = nil;
AGSGraphicsLayer * __ednLitePolylineGraphicsLayer = nil;
AGSGraphicsLayer * __ednLitePolygonGraphicsLayer = nil;
AGSSketchGraphicsLayer * __ednLiteSketchGraphicsLayer = nil;
id<AGSMapViewTouchDelegate> __ednLiteTempTouchDelegate = nil;

AGSGraphic * __ednLiteCurrentEditingGraphic = nil;

#define kEDNLiteGraphicsLayerName_Point @"ednLitePointGraphicsLayer"
#define kEDNLiteGraphicsLayerName_Polyline @"ednLitePolylineGraphicsLayer"
#define kEDNLiteGraphicsLayerName_Polygon @"ednLitePolygonGraphicsLayer"

#define kEdnLiteGraphicTag @"iOSLiteAPI"
#define kEdnLiteGraphicTagKey @"createdBy"

#define kEDNLiteSketchGraphicsLayerName @"ednLiteSketchGraphcisLayer"

#pragma mark - Add Graphics Programatically
- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude
{
    AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
	return [self addPoint:pt];
}

- (AGSGraphic *) addPoint:(AGSPoint *)point
{    
    AGSGraphic *g = [self __ednLiteGetDefaultGraphicForGeometry:point];
    
    [self __ednLiteAddGraphicToAppropriateGraphicsLayer:g];
    
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

    AGSGraphic *g = [self __ednLiteGetDefaultGraphicForGeometry:line];

    [self __ednLiteAddGraphicToAppropriateGraphicsLayer:g];

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

    AGSGraphic *g = [self __ednLiteGetDefaultGraphicForGeometry:poly];

    [self __ednLiteAddGraphicToAppropriateGraphicsLayer:g];

    return g;
}

#pragma mark - Clear graphics from the map
- (void) clearGraphics:(EDNLiteGraphicsLayerType)layerType
{
    AGSGraphicsLayer *gl = nil;
    if (layerType & EDNLiteGraphicsLayerTypePoint)
    {
        gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
    
    if (layerType & EDNLiteGraphicsLayerTypePolyline)
    {
        gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolyline];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
    
    if (layerType & EDNLiteGraphicsLayerTypePolygon)
    {
        gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolygon];
        [gl removeAllGraphics];
        [gl dataChanged];
    }
}

- (void) clearGraphics
{
    [self clearGraphics:(EDNLiteGraphicsLayerTypePoint + 
                         EDNLiteGraphicsLayerTypePolyline +
                         EDNLiteGraphicsLayerTypePolygon)];
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

#pragma mark - Edit graphic selected from the map
- (AGSGraphic *) editGraphicFromMapViewDidClickAtPoint:(NSDictionary *)graphics
{
    AGSGraphic *graphicToEdit = nil;
    
    for (NSString *layerName in graphics.allKeys)
    {
        if (layerName == kEDNLiteGraphicsLayerName_Point ||
            layerName == kEDNLiteGraphicsLayerName_Polyline ||
            layerName == kEDNLiteGraphicsLayerName_Polygon)
        {
            NSArray *graphicsToEditFromLayer = [graphics objectForKey:layerName];
            if (graphicsToEditFromLayer.count > 0)
            {
                graphicToEdit = [graphicsToEditFromLayer objectAtIndex:0];
                break;
            }
        }
    }

    [self __ednLiteEditGraphic:graphicToEdit];
    
    return graphicToEdit;
}

#pragma mark - Create and Edit new graphics
- (void) editNewPoint
{
    [self __ednLiteEditGeometry:[[AGSMutablePoint alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) editNewMultipoint
{
    [self __ednLiteEditGeometry:[[AGSMutableMultipoint alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) editNewLine
{
    [self __ednLiteEditGeometry:[[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

- (void) editNewPolygon
{
    [self __ednLiteEditGeometry:[[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]]];
}

#pragma mark - Save edit/create
- (AGSGraphic *) saveCurrentEdit
{
    if (__ednLiteSketchGraphicsLayer)
    {
        // Update the graphics geometry
        AGSGeometry *editedGeometry = __ednLiteSketchGraphicsLayer.geometry;
        AGSGraphic *editedGraphic = nil;
        if (__ednLiteCurrentEditingGraphic)
        {
            // Editing an existing graphic
            __ednLiteCurrentEditingGraphic.geometry = editedGeometry;
            AGSGraphicsLayer *owningLayer = __ednLiteCurrentEditingGraphic.layer;
            // Get the owning layer and refresh it.
            [owningLayer dataChanged];
            
            editedGraphic = __ednLiteCurrentEditingGraphic;
        }
        else
        {
            // Creating a new graphic
            AGSGraphic *g = [self __ednLiteGetDefaultGraphicForGeometry:editedGeometry];
            [self __ednLiteAddGraphicToAppropriateGraphicsLayer:g];
            
            editedGraphic = g;
        }
        
        // Set the UI interaction back to how it was before.
        __ednLiteSketchGraphicsLayer.geometry = nil;
        __ednLiteCurrentEditingGraphic = nil;
        self.touchDelegate = __ednLiteTempTouchDelegate;
        __ednLiteTempTouchDelegate = nil;
        
        return editedGraphic;
    }
    
    return nil;
}

#pragma mark - Cancel edit/create
- (void) cancelCurrentEdit
{
    if (__ednLiteSketchGraphicsLayer)
    {
        // Set the UI interaction back to how it was before.
        __ednLiteSketchGraphicsLayer.geometry = nil;
        __ednLiteCurrentEditingGraphic = nil;
        self.touchDelegate = __ednLiteTempTouchDelegate;
        __ednLiteTempTouchDelegate = nil;
    }
}

#pragma mark - Accessors to useful objects for UI feedback during editing
- (NSUndoManager *) getUndoManagerForGraphicsEdits
{
    if (__ednLiteSketchGraphicsLayer)
    {
        return __ednLiteSketchGraphicsLayer.undoManager;
    }
    return nil;
}

- (AGSGeometry *) getCurrentEditGeometry
{
    if (__ednLiteSketchGraphicsLayer)
    {
        return __ednLiteSketchGraphicsLayer.geometry;
    }
    return nil;
}

- (AGSGraphicsLayer *) getGraphicsLayer:(EDNLiteGraphicsLayerType)layerType
{
    if (!__ednLitePointGraphicsLayer)
    {
        // Create three graphics layers and add them to the map.
        __ednLitePointGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        __ednLitePolylineGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        __ednLitePolygonGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(__ednLiteGraphicsBasemapDidChange:) 
                                                     name:@"BasemapDidChange"
                                                   object:self];
        
    }
    
    [self __ensureEdnLiteGraphicsLayersAdded];
    
    switch (layerType) {
        case EDNLiteGraphicsLayerTypePoint:
            return __ednLitePointGraphicsLayer;
            
        case EDNLiteGraphicsLayerTypePolyline:
            return __ednLitePolylineGraphicsLayer;
            
        case EDNLiteGraphicsLayerTypePolygon:
            return __ednLitePolygonGraphicsLayer;
    }
    
    return nil;
}

#pragma mark - Internal/Private

- (void) __ednLiteEditGraphic:(AGSGraphic *)graphicToEdit
{
    if (graphicToEdit)
    {
        [self __ednLiteEditGeometry:graphicToEdit.geometry];
        __ednLiteCurrentEditingGraphic = graphicToEdit;
    }
}

- (void) __ednLiteEditGeometry:(AGSGeometry *)geom
{
    if (geom)
    {
        if (!__ednLiteSketchGraphicsLayer)
        {
            __ednLiteSketchGraphicsLayer = [AGSSketchGraphicsLayer graphicsLayer];
        }
        
        // The layer should always be the topmost layer so, even if we've added it previously, let's
        // remove it now so we can add it to the top again.
        if (![self getLayerForName:kEDNLiteSketchGraphicsLayerName])
        {
            [self removeMapLayerWithName:kEDNLiteSketchGraphicsLayerName];
        }

        [self addMapLayer:__ednLiteSketchGraphicsLayer withName:kEDNLiteSketchGraphicsLayerName];
        
        // Store the real touch delegate
        if (!__ednLiteTempTouchDelegate &&
            self.touchDelegate != __ednLiteSketchGraphicsLayer)
        {
            __ednLiteTempTouchDelegate = self.touchDelegate;
        }
        
        // Set the sketch layer to be the touch delegate.
        self.touchDelegate = __ednLiteSketchGraphicsLayer;
        
        AGSGeometry *editGeom = nil;
        editGeom = [geom mutableCopy];
        __ednLiteSketchGraphicsLayer.geometry = editGeom;
    }
}

- (void) __ensureEdnLiteGraphicsLayersAdded
{
	if (![self getLayerForName:kEDNLiteGraphicsLayerName_Polygon])
    {
        [self addMapLayer:__ednLitePolygonGraphicsLayer withName:kEDNLiteGraphicsLayerName_Polygon];
    }
	
    if (![self getLayerForName:kEDNLiteGraphicsLayerName_Polyline])
    {
        [self addMapLayer:__ednLitePolylineGraphicsLayer withName:kEDNLiteGraphicsLayerName_Polyline];
    }
    
    if (![self getLayerForName:kEDNLiteGraphicsLayerName_Point])
    {
        [self addMapLayer:__ednLitePointGraphicsLayer withName:kEDNLiteGraphicsLayerName_Point];
    }
}

- (void) __initEdnLiteGraphics
{
    // Asking for any layer will ensure they're all created and added.
    [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
}

- (void) __ednLiteGraphicsBasemapDidChange:(NSNotification *)notification
{
	[self __ensureEdnLiteGraphicsLayersAdded];
}

- (AGSSymbol *) __ednLiteGetDefaultSymbolForGeometry:(AGSGeometry *)geom
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

- (AGSGraphic *) __ednLiteGetDefaultGraphicForGeometry:(AGSGeometry *)geom
{  
    // Create a graphic with an appropriate symbol and attributes, given a geometry.
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:geom
                                             symbol:[self __ednLiteGetDefaultSymbolForGeometry:geom]
                                         attributes:[NSDictionary dictionaryWithObject:kEdnLiteGraphicTag forKey:kEdnLiteGraphicTagKey]
                               infoTemplateDelegate:nil];
    return g;
}

- (void) __ednLiteAddGraphicToAppropriateGraphicsLayer:(AGSGraphic *)graphic
{
    // Figure out what type of geometry the graphic is, and add the graphic to the appropriate layer.
    if (graphic)
    {
        AGSGeometry *geom = graphic.geometry;
        AGSGraphicsLayer *gLayer = nil;
        if ([geom isKindOfClass:[AGSPoint class]] ||
            [geom isKindOfClass:[AGSMultipoint class]])
        {
            gLayer = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
        }
        else if ([geom isKindOfClass:[AGSPolyline class]])
        {
            gLayer = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolyline];
        }
        else if ([geom isKindOfClass:[AGSPolygon class]])
        {
            gLayer = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolygon];
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

- (NSArray *) __ednLiteGetArrayFromArguments:(NSNumber *)first arguments:(va_list)otherArgs
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
