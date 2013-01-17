//
//  EQSHelper.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSBasemapTypeEnum.h"

extern AGSUnits AGSUnitsSmallAlternative(AGSUnits sourceUnit);
extern AGSAreaUnits AGSAreaUnitsFromAGSUnits(AGSUnits units);
extern NSString* NSStringFromNSTimeInterval(NSTimeInterval interval);
extern NSString* NSStringFromLengthAndUnit(double length, AGSUnits unit);

extern NSString* NSStringFromAGSDirectionSetDistance(AGSDirectionSet *directions);
extern NSString* NSStringFromAGSDirectionGraphicDistance(AGSDirectionGraphic *graphic);

extern NSString* NSStringFromAGSDirectionSetTime(AGSDirectionSet *directions);
extern NSString* NSStringFromAGSDirectionGraphicTime(AGSDirectionGraphic *graphic);

@interface EQSHelper : NSObject
// Translate between ArcGIS Online/Bing/Google tiling scheme scale levels (1-20) and actual scale value.
+ (double) getScaleForLevel:(NSUInteger)level;
+ (NSUInteger) getLevelForScale:(double)scale;

// Basemap functions
+ (NSString *) getBasemapName:(EQSBasemapType)basemapType;
+ (AGSWebMap *) getBasemapWebMap:(EQSBasemapType)basemapType;
+ (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType;
+ (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID;
@end