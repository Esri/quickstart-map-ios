//
//  EDNMapViewLite+Basemaps.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Basemaps.h"

@interface AGSMapView()<AGSWebMapDelegate, AGSPortalItemDelegate>
@end

@implementation AGSMapView (Basemaps)

AGSEnvelope *__ednLiteBasemaps_oldExtent = nil;
EDNLiteBasemapType __ednLiteCurrentBasemapType = 0;
NSString *EDN_LITE_BASEMAP_LAYER_NAME = @"ednLiteBasemap";


- (void) setBasemap:(EDNLiteBasemapType)basemapType
{
    BOOL useWebMaps = YES;
    __ednLiteCurrentBasemapType = basemapType;
    
    if (useWebMaps)
    {
        __ednLiteBasemaps_oldExtent = self.visibleArea.envelope;
        
        static AGSWebMap *currentWebMap = nil;
        if (currentWebMap != nil)
        {
            currentWebMap.delegate = nil;
        }
        
        currentWebMap = [EDNLiteHelper getBasemapWebMap:basemapType];
        currentWebMap.delegate = self;
        
        [currentWebMap openIntoMapView:self];
    }
    else {
        AGSTiledLayer *newBasemapLayer = [EDNLiteHelper getBasemapTiledLayer:basemapType];
        
        [self removeMapLayerWithName:EDN_LITE_BASEMAP_LAYER_NAME];
        [self insertMapLayer:newBasemapLayer withName:EDN_LITE_BASEMAP_LAYER_NAME atIndex:0];
        [self postNewBasemapNotification:basemapType forPortalItem:nil];
    }
}

- (void)didOpenWebMap:(AGSWebMap *)webMap intoMapView:(AGSMapView *)mapView
{
    [mapView zoomToEnvelope:__ednLiteBasemaps_oldExtent animated:NO];
    __ednLiteBasemaps_oldExtent = nil;

    if (__ednLiteCurrentBasemapType == EDNLiteBasemapHybrid)
    {
        NSArray *layers = webMap.operationalLayers;
        if (layers.count > 0)
        {
            AGSWebMapLayerInfo *layerInfo = [layers objectAtIndex:0];
            AGSTiledLayer *roadLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:layerInfo.URL];
            [mapView addMapLayer:roadLayer withName:@"roads"];
        }
    }
    
    AGSPortalItem *pi = webMap.portalItem;
    [self postNewBasemapNotification:__ednLiteCurrentBasemapType forPortalItem:pi];
    
    if ([self respondsToSelector:@selector(__initEdnLiteGraphics)])
    {
        // The Graphics Category is included, let's load the graphics layers
        // back into the map.
        [self performSelector:@selector(__initEdnLiteGraphics)];
    }
}

- (void)webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load webmap");
}

- (void)postNewBasemapNotification:(EDNLiteBasemapType)basemapType forPortalItem:(AGSPortalItem *)portalItem
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:basemapType], @"BasemapType", nil];

    if (portalItem != nil)
    {
        [userInfo setObject:portalItem forKey:@"PortalItem"];        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BasemapDidChange" 
                                                        object:self 
                                                      userInfo:userInfo];
}
@end
