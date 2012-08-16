//
//  STXHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "STXBasemapTypeEnum.h"

#define kSTXGeolocationSucceeded @"STXGeolocationSucceeded"
#define kSTXGeolocationError @"STXGeolocationError"
#define kSTXGeolocationSucceededLocationKey @"newLocation"

@interface STXHelper : NSObject
// Translate a Google/Bing/ArcGIS Online tiling scheme scale number (1-20) to an actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;

// Basemap Helpers
+ (NSString *) getBasemapName:(STXBasemapType)basemapType;
+ (AGSWebMap *) getBasemapWebMap:(STXBasemapType)basemapType;
+ (NSString *) getPortalItemIDForBasemap:(STXBasemapType)basemapType;
+ (STXBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID;
+ (AGSTiledLayer *) getBasemapTiledLayer:(STXBasemapType)basemapType;
+ (NSArray *) getBasemapSupplementalTiledLayers:(STXBasemapType)basemapType;

// Convenience functions for translating to Web Mercator Auxiliary Sphere spatial reference
+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Long:(double) longitude;
+ (AGSPoint *) getWebMercatorAuxSpherePointFromPoint:(AGSPoint *)wgs84Point;
+ (AGSPoint *) getWGS84PointFromPoint:(AGSPoint *)webMercatorPoint;

// Call getLocation and wait for a notification response of either kSTXGeolocationSucceeded or
// kSTXGeolocationError. In the case of success, read the AGSPoint from the notification's
// userInfo dictionary using the kSTXGeolocationSucceededLocationKey key.
+ (void) getGeolocation;
+ (BOOL) isGeolocationEnabled;

// Queuing...
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView;
@end
