//
//  EQSHelper.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "EQSBasemapTypeEnum.h"

@interface EQSHelper : NSObject
// Translate between ArcGIS Online/Bing/Google tiling scheme scale levels (1-20) and actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;
+ (NSUInteger) getLevelForScale:(double)scale;

// Basemap functions
+ (NSString *) getBasemapName:(EQSBasemapType)basemapType;
+ (AGSWebMap *) getBasemapWebMap:(EQSBasemapType)basemapType;
+ (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType;
+ (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID;

// Queuing. Some operations cannot be performed until the AGSMapView has loaded.
// This single function takes a code block and only executes it once the provided
// AGSMapView enters a loaded state.
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView;
@end
