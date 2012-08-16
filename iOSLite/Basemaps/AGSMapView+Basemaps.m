//
//  AGSMapView+Basemaps.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Basemaps.h"
#import "AGSLayer+Basemap.h"
#import "STXHelper.h"

#define kSTXBasemapLayerName @"STXBasemapLayer"

@interface AGSMapView()<AGSWebMapDelegate>
@end

@implementation AGSMapView (Basemaps)

AGSEnvelope *__stxBasemaps_oldExtent = nil;
STXBasemapType __stxCurrentBasemapType = 0;


- (void) setBasemap:(STXBasemapType)basemapType
{
    BOOL useWebMaps = YES;
    __stxCurrentBasemapType = basemapType;
    
    if (useWebMaps)
    {
        __stxBasemaps_oldExtent = self.visibleArea.envelope;
        
        static AGSWebMap *currentWebMap = nil;
        if (currentWebMap != nil)
        {
            currentWebMap.delegate = nil;
        }
        
        currentWebMap = [STXHelper getBasemapWebMap:basemapType];
        currentWebMap.delegate = self;
        
        [currentWebMap openIntoMapView:self];
    }
    else {
        // Get the new basemap layer and supplemental layers.
        AGSTiledLayer *newBasemapLayer = [STXHelper getBasemapTiledLayer:basemapType];
        [newBasemapLayer setIsSTXBasemapLayer:YES];

        NSArray *supplementalBasemapLayers = [STXHelper getBasemapSupplementalTiledLayers:basemapType];

        // Remove current basemap layers.
        NSMutableArray *layerNamesToRemove = [NSMutableArray array];
        for (AGSLayer *layer in self.mapLayers) {
            if ([layer isSTXBasemapLayer])
            {
                [layerNamesToRemove addObject:layer.name];
            }
        }
        
        for (NSString *layerNameToRemove in layerNamesToRemove) {
            NSLog(@"Removing basemap layer: %@", layerNameToRemove);
            [self removeMapLayerWithName:layerNameToRemove];
        }

        // Add the new basemap layer
        NSLog(@"Adding basemap layer: %@", kSTXBasemapLayerName);
        [self insertMapLayer:newBasemapLayer withName:kSTXBasemapLayerName atIndex:0];

        // Add any supplemental layers.
        if (supplementalBasemapLayers)
        {
            for (int i=0; i < supplementalBasemapLayers.count; i++)
            {
                AGSTiledLayer *supplementalLayer = [supplementalBasemapLayers objectAtIndex:i];
                [supplementalLayer setIsSTXBasemapLayer:YES];
                NSString *layerName = [NSString stringWithFormat:@"%@_%d", kSTXBasemapLayerName, i];
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
    [mapView zoomToEnvelope:__stxBasemaps_oldExtent animated:NO];
    __stxBasemaps_oldExtent = nil;

    if (__stxCurrentBasemapType == STXBasemapTypeHybrid)
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
        [basemapLayer setIsSTXBasemapLayer:YES];
    }
    
    AGSPortalItem *pi = webMap.portalItem;
    [self postNewBasemapNotification:__stxCurrentBasemapType forPortalItem:pi];
    
    if ([self respondsToSelector:@selector(__initSTXGraphics)])
    {
        // The Graphics Category is included, let's load the graphics layers
        // back into the map.
        [self performSelector:@selector(__initSTXGraphics)];
    }
}

- (void)webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load webmap");
}

- (void)postNewBasemapNotification:(STXBasemapType)basemapType forPortalItem:(AGSPortalItem *)portalItem
{
    // TODO - Refactor into #define constants and make public.
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:basemapType], @"BasemapType", nil];

    if (portalItem != nil)
    {
        [userInfo setObject:portalItem forKey:@"PortalItem"];        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSTXNotification_BasemapDidChange
                                                        object:self 
                                                      userInfo:userInfo];
}
@end