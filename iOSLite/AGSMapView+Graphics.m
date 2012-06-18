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

NSString * EDNLITE_GRAPHIC_TAG = @"iOSLiteAPI";
NSString * EDNLITE_GRAPHIC_TAG_KEY = @"createdBy";

#define kEDNLiteSketchGraphicsLayerName @"ednLiteSketchGraphcisLayer"

- (AGSGraphic *) editGraphicFromDidClickAtPointEvent:(NSDictionary *)graphics
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
    
    if (graphicToEdit)
    {
        if (!__ednLiteSketchGraphicsLayer)
        {
            __ednLiteSketchGraphicsLayer = [AGSSketchGraphicsLayer graphicsLayer];
        }
        
        if ([self getLayerForName:kEDNLiteSketchGraphicsLayerName])
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

        AGSGeometry *geom = graphicToEdit.geometry;
        AGSGeometry *editGeom = nil;
        editGeom = [geom mutableCopy];
        __ednLiteSketchGraphicsLayer.geometry = editGeom;
        __ednLiteCurrentEditingGraphic = graphicToEdit;
    }
    
    return graphicToEdit;
}

- (void) saveCurrentEdit
{
    if (__ednLiteSketchGraphicsLayer)
    {
        // Update the graphics geometry
        AGSGeometry *editedGeometry = __ednLiteSketchGraphicsLayer.geometry;
        __ednLiteCurrentEditingGraphic.geometry = editedGeometry;
        
        // Get the owning layer and refresh it.
        AGSGraphicsLayer *owningLayer = __ednLiteCurrentEditingGraphic.layer;
        [owningLayer dataChanged];
        
        // Set the UI interaction back to how it was before.
        __ednLiteSketchGraphicsLayer.geometry = nil;
        __ednLiteCurrentEditingGraphic = nil;
        self.touchDelegate = __ednLiteTempTouchDelegate;
        __ednLiteTempTouchDelegate = nil;
    }
}

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

    [self __ensureEdnLiteGraphicsLayerAdded];

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

- (void) __ensureEdnLiteGraphicsLayerAdded
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
    [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
}

- (void) __ednLiteGraphicsBasemapDidChange:(NSNotification *)notification
{
	[self __ensureEdnLiteGraphicsLayerAdded];
}

- (AGSGraphic *) addPointAtLat:(double)latitude Lng:(double)longitude
{
    AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Lon:longitude];
    
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:pt
                                             symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]]
                                         attributes:[NSDictionary dictionaryWithObject:EDNLITE_GRAPHIC_TAG forKey:EDNLITE_GRAPHIC_TAG_KEY]
                               infoTemplateDelegate:nil];
    
    AGSGraphicsLayer *gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
    [gl addGraphic:g];
    [gl dataChanged];
    return g;
}

- (NSArray *) getArrayFromArguments:(NSNumber *)first arguments:(va_list)otherArgs
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSNumber *nextNumber = first; nextNumber != nil; nextNumber = va_arg(otherArgs, NSNumber *))
    {
        [result addObject:nextNumber];
    }

    return result;
}

- (AGSGraphic *) addLineWithLatsAndLngs:(NSNumber *)firstLatitude, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, firstLatitude);
    NSArray *nums = [self getArrayFromArguments:firstLatitude arguments:args];
    va_end(args);
    
    NSAssert1((nums.count % 2) == 0, @"Must provide an even number of NSNumbers!", nums.count);

    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [line addPathToPolyline];
    
    for (int i=0; i < nums.count; i = i + 2)
    {
        NSNumber *lat = [nums objectAtIndex:i];
        NSNumber *lon = [nums objectAtIndex:i+1];
        AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:[lat doubleValue] Lon:[lon doubleValue]];
        [line addPointToPath:pt];
    }

    AGSGraphic *g = [AGSGraphic graphicWithGeometry:line 
                                             symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2.0f]
                                         attributes:[NSDictionary dictionaryWithObject:EDNLITE_GRAPHIC_TAG forKey:EDNLITE_GRAPHIC_TAG_KEY]
                               infoTemplateDelegate:nil];

    AGSGraphicsLayer *gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolyline];
    [gl addGraphic:g];
    [gl dataChanged];
    return g;
}

- (AGSGraphic *) addPolygonWithLatsAndLngs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, firstLatitude);
    NSArray *nums = [self getArrayFromArguments:firstLatitude arguments:args];
    va_end(args);

    NSAssert1((nums.count % 2) == 0, @"Must provide an even number of NSNumbers!", nums.count);

    AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [poly addRingToPolygon];
    
    for (int i=0; i < nums.count; i = i + 2)
    {
        NSNumber *lat = [nums objectAtIndex:i];
        NSNumber *lon = [nums objectAtIndex:i+1];
        AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:[lat doubleValue] Lon:[lon doubleValue]];
        [poly addPointToRing:pt];
    }

    AGSGraphic *g = [AGSGraphic graphicWithGeometry:poly 
                                             symbol:[AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor redColor] outlineColor:[UIColor blueColor]]
                                         attributes:[NSDictionary dictionaryWithObject:EDNLITE_GRAPHIC_TAG forKey:EDNLITE_GRAPHIC_TAG_KEY]
                               infoTemplateDelegate:nil];

    AGSGraphicsLayer *gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolygon];
    [gl addGraphic:g];
    [gl dataChanged];
    return g;
}

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
@end
