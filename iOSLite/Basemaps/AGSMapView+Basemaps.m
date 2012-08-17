//
//  AGSMapView+Basemaps.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Basemaps.h"
#import "AGSLayer+Basemap.h"
#import "EQSHelper.h"

#define kEQSBasemapLayerName @"EQSBasemapLayer"

@interface AGSMapView()<AGSWebMapDelegate>
@end

@implementation AGSMapView (Basemaps)

AGSEnvelope *__eqsBasemaps_oldExtent = nil;
EQSBasemapType __eqsCurrentBasemapType = 0;


- (void) setBasemap:(EQSBasemapType)basemapType
{
    BOOL useWebMaps = YES;
    __eqsCurrentBasemapType = basemapType;
    
    if (useWebMaps)
    {
        __eqsBasemaps_oldExtent = self.visibleArea.envelope;
        
        static AGSWebMap *currentWebMap = nil;
        if (currentWebMap != nil)
        {
            currentWebMap.delegate = nil;
        }
        
        currentWebMap = [EQSHelper getBasemapWebMap:basemapType];
        currentWebMap.delegate = self;
        
        [currentWebMap openIntoMapView:self];
    }
    else {
        // Get the new basemap layer and supplemental layers.
        AGSTiledLayer *newBasemapLayer = [EQSHelper getBasemapTiledLayer:basemapType];
        [newBasemapLayer setIsEQSBasemapLayer:YES];

        NSArray *supplementalBasemapLayers = [EQSHelper getBasemapSupplementalTiledLayers:basemapType];

        // Remove current basemap layers.
        NSMutableArray *layerNamesToRemove = [NSMutableArray array];
        for (AGSLayer *layer in self.mapLayers) {
            if ([layer isEQSBasemapLayer])
            {
                [layerNamesToRemove addObject:layer.name];
            }
        }
        
        for (NSString *layerNameToRemove in layerNamesToRemove) {
            NSLog(@"Removing basemap layer: %@", layerNameToRemove);
            [self removeMapLayerWithName:layerNameToRemove];
        }

        // Add the new basemap layer
        NSLog(@"Adding basemap layer: %@", kEQSBasemapLayerName);
        [self insertMapLayer:newBasemapLayer withName:kEQSBasemapLayerName atIndex:0];

        // Add any supplemental layers.
        if (supplementalBasemapLayers)
        {
            for (int i=0; i < supplementalBasemapLayers.count; i++)
            {
                AGSTiledLayer *supplementalLayer = [supplementalBasemapLayers objectAtIndex:i];
                [supplementalLayer setIsEQSBasemapLayer:YES];
                NSString *layerName = [NSString stringWithFormat:@"%@_%d", kEQSBasemapLayerName, i];
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
    [mapView zoomToEnvelope:__eqsBasemaps_oldExtent animated:NO];
    __eqsBasemaps_oldExtent = nil;

    if (__eqsCurrentBasemapType == EQSBasemapTypeHybrid)
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
        [basemapLayer setIsEQSBasemapLayer:YES];
    }
    
    AGSPortalItem *pi = webMap.portalItem;
    [self postNewBasemapNotification:__eqsCurrentBasemapType forPortalItem:pi];
    
    if ([self respondsToSelector:@selector(__initEQSGraphics)])
    {
        // The Graphics Category is included, let's load the graphics layers
        // back into the map.
        [self performSelector:@selector(__initEQSGraphics)];
    }
}

- (void)webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load webmap");
}

- (void)postNewBasemapNotification:(EQSBasemapType)basemapType forPortalItem:(AGSPortalItem *)portalItem
{
    // TODO - Refactor into #define constants and make public.
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:basemapType], @"BasemapType", nil];

    if (portalItem != nil)
    {
        [userInfo setObject:portalItem forKey:@"PortalItem"];        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSNotification_BasemapDidChange
                                                        object:self 
                                                      userInfo:userInfo];
}
@end