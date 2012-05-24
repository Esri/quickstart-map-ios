//
//  AGSMapView+Graphics.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Graphics.h"

@implementation AGSMapView (Graphics)
AGSGraphicsLayer * __ednLitePointGraphicsLayer = nil;
AGSGraphicsLayer * __ednLitePolylineGraphicsLayer = nil;
AGSGraphicsLayer * __ednLitePolygonGraphicsLayer = nil;

NSString * EDNLITE_GRAPHICS_LAYER_NAME_PT = @"ednLitePointGraphicsLayer";
NSString * EDNLITE_GRAPHICS_LAYER_NAME_PL = @"ednLitePolylineGraphicsLayer";
NSString * EDNLITE_GRAPHICS_LAYER_NAME_PG = @"ednLitePolygonGraphicsLayer";

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
    }
    
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

- (void) __initEdnLiteGraphics
{
    [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
}

- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude
{
    AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
    AGSGraphic *g = [AGSGraphic graphicWithGeometry:pt
                                             symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]]
                                         attributes:[NSDictionary dictionaryWithObject:@"iOSLiteAPI" forKey:@"createdBy"]
                               infoTemplateDelegate:nil];
    
    AGSGraphicsLayer *gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePoint];
    [gl addGraphic:g];
    [gl dataChanged];
    return g;
}

- (AGSGraphic *) addLineWithLatsAndLongs:(NSNumber *)firstLatitude, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, firstLatitude);
    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [line addPathToPolyline];
    for (NSNumber *lat = firstLatitude; lat != nil; lat = va_arg(args, NSNumber *))
    {
        NSNumber *lon = va_arg(args, NSNumber *);
        AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:[lat doubleValue] Long:[lon doubleValue]];
        [line addPointToPath:pt];
    }
    va_end(args);

    AGSGraphic *g = [AGSGraphic graphicWithGeometry:line 
                                             symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2.0f]
                                         attributes:[NSDictionary dictionaryWithObject:@"iOSLiteAPI" forKey:@"createdBy"]
                               infoTemplateDelegate:nil];

    AGSGraphicsLayer *gl = [self getGraphicsLayer:EDNLiteGraphicsLayerTypePolyline];
    [gl addGraphic:g];
    [gl dataChanged];
    return g;
}

- (AGSGraphic *) addPolygonWithLatsAndLongs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, firstLatitude);
    AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [poly addRingToPolygon];
    for (NSNumber *lat = firstLatitude; lat != nil; lat = va_arg(args, NSNumber *))
    {
        NSNumber *lon = va_arg(args, NSNumber *);
        AGSPoint *pt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:[lat doubleValue] Long:[lon doubleValue]];
        [poly addPointToRing:pt];
    }
    va_end(args);

    AGSGraphic *g = [AGSGraphic graphicWithGeometry:poly 
                                             symbol:[AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor redColor] outlineColor:[UIColor blueColor]]
                                         attributes:[NSDictionary dictionaryWithObject:@"iOSLiteAPI" forKey:@"createdBy"]
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
