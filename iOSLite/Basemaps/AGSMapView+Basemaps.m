//
//  EDNMapViewLite+Basemaps.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Basemaps.h"
#import "AGSLayer+Basemap.h"
#import "EDNLiteHelper.h"

@interface AGSMapView()<AGSWebMapDelegate>
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
        // Get the new basemap layer and supplemental layers.
        AGSTiledLayer *newBasemapLayer = [EDNLiteHelper getBasemapTiledLayer:basemapType];
        [newBasemapLayer setIsEDNLiteBasemapLayer:YES];

        NSArray *supplementalBasemapLayers = [EDNLiteHelper getBasemapSupplementalTiledLayers:basemapType];

        // Remove current basemap layers.
        NSMutableArray *layerNamesToRemove = [NSMutableArray array];
        for (AGSLayer *layer in self.mapLayers) {
            if ([layer isEDNLiteBasemapLayer])
            {
                [layerNamesToRemove addObject:layer.name];
            }
        }
        
        for (NSString *layerNameToRemove in layerNamesToRemove) {
            NSLog(@"Removing basemap layer: %@", layerNameToRemove);
            [self removeMapLayerWithName:layerNameToRemove];
        }

        // Add the new basemap layer
        NSLog(@"Adding basemap layer: %@", EDN_LITE_BASEMAP_LAYER_NAME);
        [self insertMapLayer:newBasemapLayer withName:EDN_LITE_BASEMAP_LAYER_NAME atIndex:0];

        // Add any supplemental layers.
        if (supplementalBasemapLayers)
        {
            for (int i=0; i < supplementalBasemapLayers.count; i++)
            {
                AGSTiledLayer *supplementalLayer = [supplementalBasemapLayers objectAtIndex:i];
                [supplementalLayer setIsEDNLiteBasemapLayer:YES];
                NSString *layerName = [NSString stringWithFormat:@"%@_%d", EDN_LITE_BASEMAP_LAYER_NAME, i];
                NSLog(@"Adding basemap supplemental layer: %@", layerName);
                [self insertMapLayer:supplementalLayer withName:layerName atIndex:1+i];
            }
        }
        
        // Notify any listeners.
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

    // All the layers right now are basemap layers from whichever WebMap we loaded.
    for (AGSLayer *basemapLayer in mapView.mapLayers) {
        [basemapLayer setIsEDNLiteBasemapLayer:YES];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteNotification_BasemapDidChange
                                                        object:self 
                                                      userInfo:userInfo];
}
@end
