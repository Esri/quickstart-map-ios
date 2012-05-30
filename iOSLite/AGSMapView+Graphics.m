//
//  AGSMapView+Graphics.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Graphics.h"
#import "EDNLiteHelper.h"

@implementation AGSMapView (Graphics)
AGSGraphicsLayer * __ednLitePointGraphicsLayer = nil;
AGSGraphicsLayer * __ednLitePolylineGraphicsLayer = nil;
AGSGraphicsLayer * __ednLitePolygonGraphicsLayer = nil;

NSString * EDNLITE_GRAPHICS_LAYER_NAME_PT = @"ednLitePointGraphicsLayer";
NSString * EDNLITE_GRAPHICS_LAYER_NAME_PL = @"ednLitePolylineGraphicsLayer";
NSString * EDNLITE_GRAPHICS_LAYER_NAME_PG = @"ednLitePolygonGraphicsLayer";

NSString * EDNLITE_GRAPHIC_TAG = @"iOSLiteAPI";
NSString * EDNLITE_GRAPHIC_TAG_KEY = @"createdBy";

- (AGSLayer *) getLayerForName:(NSString *)layerName
{
    for (AGSLayer *l in self.mapLayers) {
        if (l.name == layerName)
        {
            return l;
        }
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
                                                 selector:@selector(__ednLiteRouteBasemapDidChange:) 
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
	if (![self getLayerForName:EDNLITE_GRAPHICS_LAYER_NAME_PG])
    {
        [self addMapLayer:__ednLitePolygonGraphicsLayer withName:EDNLITE_GRAPHICS_LAYER_NAME_PG];
    }
	
    if (![self getLayerForName:EDNLITE_GRAPHICS_LAYER_NAME_PL])
    {
        [self addMapLayer:__ednLitePolylineGraphicsLayer withName:EDNLITE_GRAPHICS_LAYER_NAME_PL];
    }
    
    if (![self getLayerForName:EDNLITE_GRAPHICS_LAYER_NAME_PT])
    {
        [self addMapLayer:__ednLitePointGraphicsLayer withName:EDNLITE_GRAPHICS_LAYER_NAME_PT];
    }
}

- (void) __initEdnLiteGraphics
{
    [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
}

- (void) __ednLiteRouteBasemapDidChange:(NSNotification *)notification
{
	[self __ensureEdnLiteGraphicsLayerAdded];
}

- (AGSGraphic *) addPointAtLat:(double)latitude Lng:(double)longitude
{
    AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
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

    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [line addPathToPolyline];
    
    for (int i=0; i < nums.count; i = i + 2)
    {
        NSNumber *lat = [nums objectAtIndex:i];
        NSNumber *lon = [nums objectAtIndex:i+1];
        AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:[lat doubleValue] Long:[lon doubleValue]];
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

    AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [poly addRingToPolygon];
    
    for (int i=0; i < nums.count; i = i + 2)
    {
        NSNumber *lat = [nums objectAtIndex:i];
        NSNumber *lon = [nums objectAtIndex:i+1];
        AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:[lat doubleValue] Long:[lon doubleValue]];
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
