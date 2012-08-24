//
//  AGSMapView+Basemaps.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Basemaps.h"
#import "EQSHelper.h"

#define kEQSBasemapLayerName @"EQSBasemapLayer"

@interface AGSMapView()<AGSWebMapDelegate>
@end

@implementation AGSMapView (Basemaps)

AGSEnvelope *__eqsBasemaps_oldExtent = nil;
EQSBasemapType __eqsCurrentBasemapType = 0;

- (void) setBasemap:(EQSBasemapType)basemapType
{
    __eqsCurrentBasemapType = basemapType;
    
    __eqsBasemaps_oldExtent = self.visibleArea.envelope;
    
    // Set up a static pointer to the current WebMap.
    static AGSWebMap *currentWebMap = nil;
    
    // If the WebMap is not nil, this means it's been updated since initialization.
    // We must remove ourselves as the delegate before doing anything else.
    if (currentWebMap != nil)
    {
        currentWebMap.delegate = nil;
    }
    
    // Now get the WebMap we're switching to, and set ourselves as the delegate.
    currentWebMap = [EQSHelper getBasemapWebMap:basemapType];
    currentWebMap.delegate = self;
    
    // And open it into the MapView.
    [currentWebMap openIntoMapView:self];
}

- (void)didOpenWebMap:(AGSWebMap *)webMap intoMapView:(AGSMapView *)mapView
{
    [mapView zoomToEnvelope:__eqsBasemaps_oldExtent animated:NO];
    __eqsBasemaps_oldExtent = nil;

    AGSPortalItem *pi = webMap.portalItem;
    [self postNewBasemapNotification:__eqsCurrentBasemapType forPortalItem:pi];
}

- (void)webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load webmap");
}

- (void)postNewBasemapNotification:(EQSBasemapType)basemapType forPortalItem:(AGSPortalItem *)portalItem
{
    // TODO - Refactor into #define constants and make public.
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    // Return the basemap type
    [userInfo setObject:[NSNumber numberWithInt:basemapType] forKey:kEQSNotification_BasemapDidChange_BasemapsTypeKey];

    // If we have a portal item, return that too.
    if (portalItem != nil)
    {
        [userInfo setObject:portalItem forKey:kEQSNotification_BasemapDidChange_PortalItemKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSNotification_BasemapDidChange
                                                        object:self 
                                                      userInfo:userInfo];
}
@end

@implementation NSNotification (EQSBasemaps)
- (AGSPortalItem *) basemapPortalItem
{
    return [self.userInfo objectForKey:kEQSNotification_BasemapDidChange_PortalItemKey];
}

- (EQSBasemapType) basemapType
{
    NSNumber *basemapNum = [self.userInfo objectForKey:kEQSNotification_BasemapDidChange_BasemapsTypeKey];
    return (EQSBasemapType)basemapNum.intValue;
}
@end