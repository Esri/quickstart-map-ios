//
//  EDNLiteHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNLiteHelper.h"

NSString * const EDN_SCALE_LEVELS_KEY = @"DefaultScaleLevels";
NSString * const EDN_DEFAULT_LEVEL_KEY = @"DefaultScaleLevel";
NSString * const EDN_BASEMAP_IDS_KEY = @"Basemaps";
NSString * const EDN_BASEMAP_URLS_KEY = @"BasemapURLs";

NSString * const EDN_BASEMAP_KEY_STREET = @"Street";
NSString * const EDN_BASEMAP_KEY_SATELLITE = @"Satellite";
NSString * const EDN_BASEMAP_KEY_HYBRID = @"Hybrid";
NSString * const EDN_BASEMAP_KEY_CANVAS = @"Canvas";
NSString * const EDN_BASEMAP_KEY_NATGEO = @"National Geographic";
NSString * const EDN_BASEMAP_KEY_TOPO = @"Topographic";
NSString * const EDN_BASEMAP_KEY_OSM = @"OpenStreetMap";

@interface EDNLiteHelper ()
+ (id)defaultHelper;
- (double) getScaleForLevel:(NSUInteger)level;
@end


@implementation EDNLiteHelper
BOOL __isInitialized = NO;
NSDictionary * __ednScales = nil;
NSString * __ednDefaultScaleLevel = nil;
NSDictionary * __ednBasemapWebMapIDs = nil;
NSDictionary * __ednBasemapURLs = nil;

#pragma mark - Configuration Loading and initialization
- (void)LoadConfigData
{
	if (!__isInitialized)
	{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"LiteMapConfig" ofType:@"plist"];
		NSData *pListData = [NSData dataWithContentsOfFile:path];
		NSString *error;
		NSPropertyListFormat format;
		id pList = [NSPropertyListSerialization propertyListFromData:pListData
													mutabilityOption:NSPropertyListImmutable
															  format:&format
													errorDescription:&error];
		
		if (pList)
		{
			if ([pList isKindOfClass:[NSDictionary class]])
			{
				NSDictionary *d = (NSDictionary *)pList;
				__ednScales = [d objectForKey:EDN_SCALE_LEVELS_KEY];
				__ednDefaultScaleLevel = [d objectForKey:EDN_DEFAULT_LEVEL_KEY];
                __ednBasemapWebMapIDs = [d objectForKey:EDN_BASEMAP_IDS_KEY];
                __ednBasemapURLs = [d objectForKey:EDN_BASEMAP_URLS_KEY];
                __isInitialized = YES;
			}
		}
		else 
		{
			NSLog(@"Error loading config file: %@", error);
		}
	}
}

- (id) init {
    if ([super init])
    {
        [self LoadConfigData];
    }
    return self;
}


#pragma mark - Property accessors
- (NSDictionary *) getEdnScales
{
	return __ednScales;
}

- (NSString *) getEdnDefaultScaleLevel
{
	return __ednDefaultScaleLevel;
}

- (NSString *) getBasemapKeyForEnum:(EDNLiteBasemapType)basemapType
{
    NSString *key;
    switch (basemapType) {
        case EDNLiteBasemapStreet:
            key = EDN_BASEMAP_KEY_STREET;
            break;
        case EDNLiteBasemapSatellite:
            key = EDN_BASEMAP_KEY_SATELLITE;
            break;
        case EDNLiteBasemapHybrid:
            key = EDN_BASEMAP_KEY_HYBRID;
            break;
        case EDNLiteBasemapCanvas:
            key = EDN_BASEMAP_KEY_CANVAS;
            break;
        case EDNLiteBasemapNationalGeographic:
            key = EDN_BASEMAP_KEY_NATGEO;
            break;
        case EDNLiteBasemapTopographic:
            key = EDN_BASEMAP_KEY_TOPO;
            break;
        case EDNLiteBasemapOpenStreetMap:
            key = EDN_BASEMAP_KEY_OSM;
            break;
    }
    
    return key;
}


#pragma mark - Helper functions
- (double) getScaleForLevel:(NSUInteger)level
{	
    NSString *key = [NSString stringWithFormat:@"%d", level];
    id scaleVal = [[self getEdnScales] objectForKey:key];
    if (scaleVal)
    {
        return [scaleVal doubleValue];
    }
    else
    {
        NSLog(@"Scale level %@ is invalid. Using default of %@.", key, [self getEdnDefaultScaleLevel]);
        return [[[self getEdnScales] objectForKey:[self getEdnDefaultScaleLevel]] doubleValue];
    }
}

- (AGSWebMap *) getBasemapWebMap:(EDNLiteBasemapType)basemapType
{
    NSString *key = [self getBasemapKeyForEnum:basemapType];
    NSAssert1(key != nil, @"Could not figure out which basemap you're after!", basemapType);
    
    NSString *webMapID = [__ednBasemapWebMapIDs objectForKey:key];
    NSAssert1(webMapID != nil, @"The basemap hasn't been configured properly!", key);
    
    AGSWebMap *r = [AGSWebMap webMapWithItemId:webMapID credential:nil];
    return r;
}

- (AGSTiledLayer *) getBasemapTiledLayer:(EDNLiteBasemapType)basemapType
{
    switch (basemapType) {
        case EDNLiteBasemapOpenStreetMap:
            return [AGSOpenStreetMapLayer openStreetMapLayer];
            break;

        default:
            {
                NSString *key = [self getBasemapKeyForEnum:basemapType];
                NSAssert1(key != nil, @"Could not figure out which basemap you're after!", basemapType);
                
                NSString *basemapURL = [__ednBasemapURLs objectForKey:key];
                NSAssert1(basemapURL != nil, @"The basemap hasn't been configured properly!", key);
                
                AGSTiledMapServiceLayer *basemapLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:basemapURL]];
                return basemapLayer;
            }
            break;
    }
}

#pragma mark - Static Helper functions
+ (EDNLiteHelper *)defaultHelper {
    static EDNLiteHelper *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EDNLiteHelper alloc] init];
    });
    
    return sharedInstance;
}

+ (double) getScaleForLevel:(NSUInteger)level
{
    return [[EDNLiteHelper defaultHelper] getScaleForLevel:level];
}

+ (AGSWebMap *) getBasemapWebMap:(EDNLiteBasemapType)basemapType
{
    return [[EDNLiteHelper defaultHelper] getBasemapWebMap:basemapType];
}

+ (AGSTiledLayer *) getBasemapTiledLayer:(EDNLiteBasemapType)basemapType
{
    return [[EDNLiteHelper defaultHelper] getBasemapTiledLayer:basemapType];
}

+ (NSString *) getBasemapName:(EDNLiteBasemapType)basemapType
{
    return [[EDNLiteHelper defaultHelper] getBasemapKeyForEnum:basemapType];
}

+ (AGSPoint *) getWebMercatorAuxSpherePointFromWGS84Point:(AGSPoint *)wgs84Point
{
    @try
    {
		return (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:wgs84Point 
																   toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];    
    }
    @catch (NSException *e) {
        NSLog(@"Error getting Web Mercator Point from %@: %@",wgs84Point, e); 
    }
}

+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Long:(double) longitude
{
    // Ensure we're passed sensible values for lat and long
    NSAssert1((-90 <= latitude) && (latitude <= 90), @"Latitude %f must be between -90 and 90 degrees", latitude);
    
    AGSPoint *wgs84CenterPt = [AGSPoint pointWithX:longitude y:latitude spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    return [self getWebMercatorAuxSpherePointFromWGS84Point:wgs84CenterPt];
}
@end
