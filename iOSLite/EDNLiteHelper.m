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
@property (nonatomic, strong) NSMutableDictionary *mapViewQueues;
@end


@implementation EDNLiteHelper
BOOL __isInitialized = NO;
NSDictionary * __ednScales = nil;
NSString * __ednDefaultScaleLevel = nil;
NSDictionary * __ednBasemapWebMapIDs = nil;
NSDictionary * __ednBasemapURLs = nil;

@synthesize mapViewQueues = _mapViewQueues;

#pragma mark - Queued Operations
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView
{
    // This little bit of code does some magic to queue up code blocks for execution
    // until such time as the AGSMapView is loaded. An NSOperationQueue is populated
    // with code blocks, but is not processed until the AGSMapView is observer to have
    // loaded (using KVO).
    [[EDNLiteHelper defaultHelper] queueBlock:block untilMapViewLoaded:mapView];
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

- (BOOL) basemapLayerHasSupplementLayers:(EDNLiteBasemapType)basemapType
{
    switch (basemapType) {
        case EDNLiteBasemapHybrid:
            return YES;
            
        default:
            return NO;
    }
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
                
                NSString *basemapURL = nil;
                if ([self basemapLayerHasSupplementLayers:basemapType])
                {
                    // The value is a dictionary of layer IDs
                    NSArray *allBasemapLayers = [__ednBasemapURLs objectForKey:key];
                    basemapURL = [allBasemapLayers objectAtIndex:0];
                }
                else
                {
                    // The value is a string.
                    basemapURL = [__ednBasemapURLs objectForKey:key];
                }
                NSAssert1(basemapURL != nil, @"The basemap hasn't been configured properly!", key);
                
                AGSTiledMapServiceLayer *basemapLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:basemapURL]];
                return basemapLayer;
            }
            break;
    }
}

- (NSArray *) getBasemapSupplementalTiledLayers:(EDNLiteBasemapType)basemapType
{
    if ([self basemapLayerHasSupplementLayers:basemapType])
    {
        NSString *key = [self getBasemapKeyForEnum:basemapType];
        NSAssert1(key != nil, @"Could not figure out which basemap you're after!", basemapType);

        // The value is a dictionary of layer IDs
        NSArray *allBasemapLayers = [__ednBasemapURLs objectForKey:key];
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

+ (NSArray *) getBasemapSupplementalTiledLayers:(EDNLiteBasemapType)basemapType
{
    return [[EDNLiteHelper defaultHelper] getBasemapSupplementalTiledLayers:basemapType];
}

+ (NSString *) getBasemapName:(EDNLiteBasemapType)basemapType
{
    return [[EDNLiteHelper defaultHelper] getBasemapKeyForEnum:basemapType];
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
