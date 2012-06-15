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

@interface EDNLiteHelper : NSObject
// Translate a Google/Bing/ArcGIS Online tiling scheme scale number (1-20) to an actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;

// Basemap Helpers
+ (NSString *) getBasemapName:(EDNLiteBasemapType)basemapType;
+ (AGSWebMap *) getBasemapWebMap:(EDNLiteBasemapType)basemapType;
+ (AGSTiledLayer *) getBasemapTiledLayer:(EDNLiteBasemapType)basemapType;
+ (NSArray *) getBasemapSupplementalTiledLayers:(EDNLiteBasemapType)basemapType;

// Convenience functions for translating to Web Mercator Auxiliary Sphere spatial reference
+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Lon:(double) longitude;
+ (AGSPoint *) getWebMercatorAuxSpherePointFromWGS84Point:(AGSPoint *)wgs84Point;
+ (AGSPoint *) getWGS84PointFromWebMercatorAuxSpherePoint:(AGSPoint *)webMercatorPoint;

// Queuing...
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView;
@end
