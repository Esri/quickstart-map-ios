//
//  EDNLiteHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "EDNLiteBasemaps.h"

#define kEDNLiteGeolocationSucceeded @"EDNLiteGeolocationSucceeded"
#define kEDNLiteGeolocationError @"EDNLiteGeolocationError"
#define kEDNLiteGeolocationSucceededLocationKey @"newLocation"

@interface EDNLiteHelper : NSObject
// Translate a Google/Bing/ArcGIS Online tiling scheme scale number (1-20) to an actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;

// Basemap Helpers
+ (NSString *) getBasemapName:(EDNLiteBasemapType)basemapType;
+ (AGSWebMap *) getBasemapWebMap:(EDNLiteBasemapType)basemapType;
- (NSString *) getPortalItemIDForBasemap:(EDNLiteBasemapType)basemapType;
+ (AGSTiledLayer *) getBasemapTiledLayer:(EDNLiteBasemapType)basemapType;
+ (NSArray *) getBasemapSupplementalTiledLayers:(EDNLiteBasemapType)basemapType;

// Convenience functions for translating to Web Mercator Auxiliary Sphere spatial reference
+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Long:(double) longitude;
+ (AGSPoint *) getWebMercatorAuxSpherePointFromPoint:(AGSPoint *)wgs84Point;
+ (AGSPoint *) getWGS84PointFromPoint:(AGSPoint *)webMercatorPoint;

// Call getLocation and wait for a notification response of either kEDNLiteGeolocationSucceeded or
// kEDNLiteGeolocationError. In the case of success, read the AGSPoint from the notification's
// userInfo dictionary using the kEDNLiteGeolocationSucceededLocationKey key.
+ (void) getGeolocation;
+ (BOOL) isGeolocationEnabled;

// Queuing...
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView;
@end
