//
//  EDNLiteHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

typedef enum {
    EDNLiteBasemapStreet = 1,
    EDNLiteBasemapSatellite = 2,
    EDNLiteBasemapHybrid = 3,
    EDNLiteBasemapCanvas = 4,
    EDNLiteBasemapNationalGeographic = 5,
    EDNLiteBasemapTopographic = 6,
    EDNLiteBasemapOpenStreetMap = 7,
    
    EDNLiteBasemapFirst = EDNLiteBasemapStreet,
    EDNLiteBasemapLast = EDNLiteBasemapOpenStreetMap
} EDNLiteBasemapType;

@interface EDNLiteHelper : NSObject
// Translate a Google/Bing/ArcGIS Online tiling scheme scale number (1-20) to an actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;
+ (AGSWebMap *) getBasemapWebMap:(EDNLiteBasemapType)basemapType;
+ (AGSTiledLayer *) getBasemapTiledLayer:(EDNLiteBasemapType)basemapType;

// Convenience functions for translating to Web Mercator Auxiliary Sphere spatial reference
+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Long:(double) longitude;
+ (AGSPoint *) getWebMercatorAuxSpherePointFromWGS84Point:(AGSPoint *)wgs84Point;

// Helpers
+ (NSString *) getBasemapName:(EDNLiteBasemapType)basemapType;
@end
