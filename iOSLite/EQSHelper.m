//
//  EQSHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSHelper.h"

#define kEQSConfigKey_ScaleLevels @"DefaultScaleLevels"
#define kEQSConfigKey_DefaultScaleLevel @"DefaultScaleLevel"
#define kEQSConfigKey_BasemapPortalItemIDs @"Basemaps"
#define kEQSConfigKey_BasemapURLs @"BasemapURLs"

#define kEQSConfigKey_Basemap_Street @"Street"
#define kEQSConfigKey_Basemap_Satellite @"Satellite"
#define kEQSConfigKey_Basemap_Hybrid @"Hybrid"
#define kEQSConfigKey_Basemap_Canvas @"Canvas"
#define kEQSConfigKey_Basemap_NatGeo @"National Geographic"
#define kEQSConfigKey_Basemap_Topographic @"Topographic"
#define kEQSConfigKey_Basemap_OSM @"OpenStreetMap"

@interface EQSHelper () <CLLocationManagerDelegate>
+ (id)defaultHelper;
- (double) getScaleForLevel:(NSUInteger)level;
@property (nonatomic, strong) NSMutableDictionary *mapViewQueues;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end


@implementation EQSHelper
BOOL __isInitialized = NO;
NSDictionary * __eqsScales = nil;
NSString * __eqsDefaultScaleLevel = nil;
NSDictionary * __eqsBasemapWebMapIDs = nil;
NSDictionary * __eqsBasemapURLs = nil;

@synthesize mapViewQueues = _mapViewQueues;

@synthesize locationManager = _locationManager;

#pragma mark - Queued Operations
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView
{
    // This little bit of code does some magic to queue up code blocks for execution
    // until such time as the AGSMapView is loaded. An NSOperationQueue is populated
    // with code blocks, but is not processed until the AGSMapView is observer to have
    // loaded (using KVO).
    [[EQSHelper defaultHelper] queueBlock:block untilMapViewLoaded:mapView];
}

- (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView
{
    if (!self.mapViewQueues)
    {
        // Lazy Init
        self.mapViewQueues = [NSMutableDictionary dictionary];
    }
    
    NSNumber *key = [self getHashForMapView:mapView];
    NSMutableArray *ops = [self.mapViewQueues objectForKey:key];
    if (!ops)
    {
        // Each mapView object gets its own NSOperationQueue to queue up operations until the map has loaded.
        ops = [NSMutableArray array];
        // Add it to our dictionary to find later.
        [self.mapViewQueues setObject:ops forKey:key];
        // Watch the AGSMapView to see when it loads.
        [mapView addObserver:self forKeyPath:@"loaded" options:NSKeyValueObservingOptionNew context:(__bridge_retained void *)key];
    }
    // And add the block to the queue.
    [ops addObject:[NSBlockOperation blockOperationWithBlock:block]];
}

- (NSNumber *) getHashForMapView:(AGSMapView *)mapView
{
    NSNumber *hashKey = [NSNumber numberWithInteger:[mapView hash]];
    return hashKey;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"loaded" && 
        self.mapViewQueues != nil)
    {
        // Get the map view whose loaded value just changed.
        AGSMapView *theMapView = (AGSMapView *)object;

        if (theMapView.loaded)
        {
            // It just changed to Loaded. We can now run the queued operations
            // that rely on the MapView being loaded.
            //
            // First, take the hashcode and dig out the list of code blocks that's specific to the loaded AGSMapView
            NSNumber *key = (__bridge_transfer NSNumber *)context;
            NSMutableArray *ops = [self.mapViewQueues objectForKey:key];
            if (ops)
            {
                // Don't need the queue of operations any more
                [self.mapViewQueues removeObjectForKey:key];
                // Don't need to watch any more.
                [theMapView removeObserver:self forKeyPath:@"loaded"];
                // Add all the code blocks to the mainQueue. This is the thread we want UI stuff to run on, and these will
                // be UI operations.
                for (NSBlockOperation *op in ops) 
                {
                    // Add each queued operation to the Main OperationQueue...
                    // They'll get run as soon as possible now.
                    [[NSOperationQueue mainQueue] addOperation:op];
                }
            }
        }
    }
}

#pragma mark - Geolocation (GPS)
+ (void) getGeolocation
{
	EQSHelper *defaultHelper = [EQSHelper defaultHelper];
	
    if (!defaultHelper.locationManager)
    {
        defaultHelper.locationManager = [[CLLocationManager alloc] init];
        defaultHelper.locationManager.delegate = defaultHelper;
        defaultHelper.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        defaultHelper.locationManager.distanceFilter = 20;
    }
    [defaultHelper.locationManager startUpdatingLocation];
}

+ (BOOL) isGeolocationEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
	NSLog(@"Located me at %.4f,%.4f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:newLocation
														 forKey:kEQSGeolocationSucceededLocationKey];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeolocationSucceeded
                                                        object:[EQSHelper class]
                                                      userInfo:userInfo];
	self.locationManager = nil;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeolocationError
                                                        object:[EQSHelper class]
                                                      userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:@"error"]];
	NSLog(@"Error getting location: %@", error);
    self.locationManager = nil;
}

#pragma mark - Configuration Loading and initialization
- (void)LoadConfigData
{
	if (!__isInitialized)
	{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"EQSConfig" ofType:@"plist"];
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
				__eqsScales = [d objectForKey:kEQSConfigKey_ScaleLevels];
				__eqsDefaultScaleLevel = [d objectForKey:kEQSConfigKey_DefaultScaleLevel];
                __eqsBasemapWebMapIDs = [d objectForKey:kEQSConfigKey_BasemapPortalItemIDs];
                __eqsBasemapURLs = [d objectForKey:kEQSConfigKey_BasemapURLs];
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
	return __eqsScales;
}

- (NSString *) getEdnDefaultScaleLevel
{
	return __eqsDefaultScaleLevel;
}

- (NSString *) getBasemapKeyForEnum:(EQSBasemapType)basemapType
{
    NSString *key;
    switch (basemapType) {
        case EQSBasemapTypeStreet:
            key = kEQSConfigKey_Basemap_Street;
            break;
        case EQSBasemapTypeSatellite:
            key = kEQSConfigKey_Basemap_Satellite;
            break;
        case EQSBasemapTypeHybrid:
            key = kEQSConfigKey_Basemap_Hybrid;
            break;
        case EQSBasemapTypeCanvas:
            key = kEQSConfigKey_Basemap_Canvas;
            break;
        case EQSBasemapTypeNationalGeographic:
            key = kEQSConfigKey_Basemap_NatGeo;
            break;
        case EQSBasemapTypeTopographic:
            key = kEQSConfigKey_Basemap_Topographic;
            break;
        case EQSBasemapTypeOpenStreetMap:
            key = kEQSConfigKey_Basemap_OSM;
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

+ (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType
{
    return [[EQSHelper defaultHelper] getPortalItemIDForBasemap:basemapType];
}

- (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType
{
    NSString *key = [self getBasemapKeyForEnum:basemapType];
    NSAssert1(key != nil, @"Could not figure out which basemap you're after!", basemapType);
    
    NSString *webMapID = [__eqsBasemapWebMapIDs objectForKey:key];
    NSAssert1(webMapID != nil, @"The basemap hasn't been configured properly!", key);
    
	return webMapID;
}

+ (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID
{
	return [[EQSHelper defaultHelper] getBasemapTypeForPortalItemID:portalItemID];
}

- (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID
{
	NSString *foundKey = nil;
	for (int i=0; i < __eqsBasemapWebMapIDs.count; i++) {
		NSString *key = [__eqsBasemapWebMapIDs.allKeys objectAtIndex:i];
		NSString *val = [__eqsBasemapWebMapIDs objectForKey:key];
		if ([val isEqualToString:portalItemID])
		{
			foundKey = key;
			break;
		}
	}
	
	if (foundKey)
	{
		EQSBasemapType type = EQSBasemapTypeFirst;
		if ([foundKey isEqualToString:kEQSConfigKey_Basemap_Street])
			type = EQSBasemapTypeStreet;
		else if ([foundKey isEqualToString:kEQSConfigKey_Basemap_Satellite])
			type = EQSBasemapTypeSatellite;
		else if ([foundKey isEqualToString:kEQSConfigKey_Basemap_Hybrid])
			type = EQSBasemapTypeHybrid;
		else if ([foundKey isEqualToString:kEQSConfigKey_Basemap_Canvas])
			type = EQSBasemapTypeCanvas;
		else if ([foundKey isEqualToString:kEQSConfigKey_Basemap_NatGeo])
			type = EQSBasemapTypeNationalGeographic;
		else if ([foundKey isEqualToString:kEQSConfigKey_Basemap_Topographic])
			type = EQSBasemapTypeTopographic;
		else if ([foundKey isEqualToString:kEQSConfigKey_Basemap_OSM])
			type = EQSBasemapTypeOpenStreetMap;
		
		return type;
	}
	
	return 0;
}

- (AGSWebMap *) getBasemapWebMap:(EQSBasemapType)basemapType
{
	NSString *webMapID = [self getPortalItemIDForBasemap:basemapType];
    AGSWebMap *r = [AGSWebMap webMapWithItemId:webMapID credential:nil];
    return r;
}

- (BOOL) basemapLayerHasSupplementLayers:(EQSBasemapType)basemapType
{
    switch (basemapType) {
        case EQSBasemapTypeHybrid:
            return YES;
            
        default:
            return NO;
    }
}

- (AGSTiledLayer *) getBasemapTiledLayer:(EQSBasemapType)basemapType
{
    switch (basemapType) {
        case EQSBasemapTypeOpenStreetMap:
            return [AGSOpenStreetMapLayer openStreetMapLayer];
            break;

        default:
            {
                NSString *key = [self getBasemapKeyForEnum:basemapType];
                NSAssert1(key != nil, @"Could not figure out which basemap you're after!", basemapType);
                
                NSString *basemapURL = nil;
                if ([self basemapLayerHasSupplementLayers:basemapType])
                {
                    // The value is a dictionary of layer IDs
                    NSArray *allBasemapLayers = [__eqsBasemapURLs objectForKey:key];
                    basemapURL = [allBasemapLayers objectAtIndex:0];
                }
                else
                {
                    // The value is a string.
                    basemapURL = [__eqsBasemapURLs objectForKey:key];
                }
                NSAssert1(basemapURL != nil, @"The basemap hasn't been configured properly!", key);
                
                AGSTiledMapServiceLayer *basemapLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:basemapURL]];
                return basemapLayer;
            }
            break;
    }
}

- (NSArray *) getBasemapSupplementalTiledLayers:(EQSBasemapType)basemapType
{
    if ([self basemapLayerHasSupplementLayers:basemapType])
    {
        NSString *key = [self getBasemapKeyForEnum:basemapType];
        NSAssert1(key != nil, @"Could not figure out which basemap you're after!", basemapType);

        // The value is a dictionary of layer IDs
        NSArray *allBasemapLayers = [__eqsBasemapURLs objectForKey:key];
        NSMutableArray *results = [NSMutableArray array];
        for (int i = 1; i < allBasemapLayers.count; i++)
        {
            NSString *url = [allBasemapLayers objectAtIndex:i];
            AGSTiledMapServiceLayer *newlayer = [AGSTiledMapServiceLayer
                                                 tiledMapServiceLayerWithURL:[NSURL URLWithString:url]];
            [results addObject:newlayer];
        }
        return results;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Static Helper functions
+ (EQSHelper *)defaultHelper {
    static EQSHelper *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQSHelper alloc] init];
    });
    
    return sharedInstance;
}

+ (double) getScaleForLevel:(NSUInteger)level
{
    return [[EQSHelper defaultHelper] getScaleForLevel:level];
}

+ (AGSWebMap *) getBasemapWebMap:(EQSBasemapType)basemapType
{
    return [[EQSHelper defaultHelper] getBasemapWebMap:basemapType];
}

+ (AGSTiledLayer *) getBasemapTiledLayer:(EQSBasemapType)basemapType
{
    return [[EQSHelper defaultHelper] getBasemapTiledLayer:basemapType];
}

+ (NSArray *) getBasemapSupplementalTiledLayers:(EQSBasemapType)basemapType
{
    return [[EQSHelper defaultHelper] getBasemapSupplementalTiledLayers:basemapType];
}

+ (NSString *) getBasemapName:(EQSBasemapType)basemapType
{
    return [[EQSHelper defaultHelper] getBasemapKeyForEnum:basemapType];
}

+ (AGSPoint *) getWebMercatorAuxSpherePointFromPoint:(AGSPoint *)wgs84Point
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

+ (AGSPoint *) getWGS84PointFromPoint:(AGSPoint *)webMercatorPoint;
{
    @try
    {
		return (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:webMercatorPoint 
																   toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];    
    }
    @catch (NSException *e) {
        NSLog(@"Error getting Web Mercator Point from %@: %@",webMercatorPoint, e); 
    }
}

+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Long:(double) longitude
{
    // Ensure we're passed sensible values for lat and long
    NSAssert1((-90 <= latitude) && (latitude <= 90), @"Latitude %f must be between -90 and 90 degrees", latitude);
    
    AGSPoint *wgs84CenterPt = [AGSPoint pointWithX:longitude y:latitude spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    return [self getWebMercatorAuxSpherePointFromPoint:wgs84CenterPt];
}
@end
