//
//  EQSHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "EQSBasemapTypeEnum.h"

@interface EQSHelper : NSObject
// Translate a Google/Bing/ArcGIS Online tiling scheme scale number (1-20) to an actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;

// Basemap Helpers
+ (NSString *) getBasemapName:(EQSBasemapType)basemapType;
+ (AGSWebMap *) getBasemapWebMap:(EQSBasemapType)basemapType;
+ (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType;
+ (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID;
+ (AGSTiledLayer *) getBasemapTiledLayer:(EQSBasemapType)basemapType;
+ (NSArray *) getBasemapSupplementalTiledLayers:(EQSBasemapType)basemapType;

// Queuing...
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView;
@end
