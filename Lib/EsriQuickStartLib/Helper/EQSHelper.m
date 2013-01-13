//
//  EQSHelper.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSHelper_int.h"
#import "AGSMapViewBase+EQSHelper.h"
#import <objc/runtime.h>

#define kEQSConfigKey_ScaleLevels @"DefaultScaleLevels"
#define kEQSConfigKey_DefaultScaleLevel @"DefaultScaleLevel"
#define kEQSConfigKey_BasemapPortalItemIDs @"Basemaps"

#define kEQSConfigKey_Basemap_Street @"Street"
#define kEQSConfigKey_Basemap_Satellite @"Satellite"
#define kEQSConfigKey_Basemap_Hybrid @"Hybrid"
#define kEQSConfigKey_Basemap_Canvas @"Canvas"
#define kEQSConfigKey_Basemap_NatGeo @"National Geographic"
#define kEQSConfigKey_Basemap_Topographic @"Topographic"
#define kEQSConfigKey_Basemap_OSM @"OpenStreetMap"

#define kEQSMapViewKey_HashCodeValue @"EQSMapViewHashCodeKey"

@interface EQSHelper () <CLLocationManagerDelegate>
- (double) getScaleForLevel:(NSUInteger)level;

@property (nonatomic, assign) BOOL isInitialized;

@property (nonatomic, strong) NSDictionary *scaleLevels;
@property (nonatomic, strong) NSString *defaultScale;

@property (nonatomic, strong) NSDictionary *basemapPortalItemIDs;

@property (nonatomic, strong) NSMutableDictionary *mapViewQueues;
@end


@implementation EQSHelper
@synthesize scaleLevels = _scaleLevels;

@synthesize isInitialized;
@synthesize defaultScale;
@synthesize basemapPortalItemIDs;

@synthesize mapViewQueues = _mapViewQueues;

#pragma mark - AGSMapViewLayerDelegate used with AGSMapViewBase+EQSHelper
-(BOOL)mapView:(AGSMapView *)mapView shouldFindGraphicsInLayer:(AGSGraphicsLayer *)graphicsLayer
       atPoint:(CGPoint)screen
      mapPoint:(AGSPoint *)mappoint
{
    // We're not the real delegate. We're here because of an intercept set up on AGSMapViewBaseClass
    // in the AGSMapViewBaseClass (EQSHelper) category's +load method.
    id<AGSMapViewLayerDelegate> realDelegate = objc_getAssociatedObject(mapView, kEQSInterceptedDelegate);
    
    // If there is a real, externally set delegate, let's pass on this call to it.
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(mapView:shouldFindGraphicsInLayer:atPoint:mapPoint:)])
    {
        return [realDelegate mapView:mapView shouldFindGraphicsInLayer:graphicsLayer
                             atPoint:screen
                            mapPoint:mappoint];
    }
    
    // Default is YES
    return YES;
}

-(void)mapViewDidLoad:(AGSMapView *)mapView
{
    // We're not the real delegate. We're here because of an intercept set up on AGSMapViewBaseClass
    // in the AGSMapViewBaseClass (EQSHelper) category's +load method.
    id<AGSMapViewLayerDelegate> realDelegate = objc_getAssociatedObject(mapView, kEQSInterceptedDelegate);

    // If there is a real, externally set delegate, let's pass on this call to it.
    if (realDelegate &&
        [realDelegate respondsToSelector:@selector(mapViewDidLoad:)])
    {
        [realDelegate mapViewDidLoad:mapView];
    }
    
    // But importantly, we now also get to raise a notification that the map view is loaded!
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSMapViewNotification_MapViewDidLoad
                                                        object:mapView];
}


#pragma mark - Queued Operations
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView withBlockName:(NSString *)blockName
{
    // This little bit of code does some magic to queue up code blocks for execution
    // until such time as the AGSMapView is loaded. An NSOperationQueue is populated
    // with code blocks, but is not processed until the AGSMapView is observer to have
    // loaded (using KVO).
    [[EQSHelper defaultHelper] queueBlock:block untilMapViewLoaded:mapView withBlockName:blockName];
}

- (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView  withBlockName:(NSString *)blockName
{
    if (mapView.loaded)
    {
        NSLog(@"AGSMapView is already loaded - executing immediately: %@", blockName);
        block();
    }
    else
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
//            [mapView addObserver:self forKeyPath:@"loaded" options:NSKeyValueObservingOptionNew context:(__bridge_retained void *)key];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleMapLoadNotification:)
                                                         name:kEQSMapViewNotification_MapViewDidLoad
                                                       object:mapView];
            mapView.layerDelegate = self;
        }

        // And add the block to the queue.
        [ops addObject:[NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"AGSMapView Loaded. Executing delayed operation: %@", blockName);
            block();
        }]];
//        [ops addObject:[NSBlockOperation blockOperationWithBlock:block]];
    }
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
//        NSNumber *key = (__bridge_transfer NSNumber *)context;
        [self handleMapLoad:theMapView];
    }
}

-(void)handleMapLoadNotification:(NSNotification *)notification
{
    AGSMapView *theMapView = notification.object;
    [self handleMapLoad:theMapView];
}

- (void)handleMapLoad:(AGSMapView *)theMapView
{
    if (theMapView.loaded)
    {
        // It just changed to Loaded. We can now run the queued operations
        // that rely on the MapView being loaded.
        //
        // First, take the hashcode and dig out the list of code blocks that's specific to the loaded AGSMapView
        NSNumber *key = [self getHashForMapView:theMapView];
        NSMutableArray *ops = [self.mapViewQueues objectForKey:key];
        if (ops)
        {
            // Don't need the queue of operations any more
            [self.mapViewQueues removeObjectForKey:key];
            // Don't need to watch any more.
//            [theMapView removeObserver:self forKeyPath:@"loaded"];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:kEQSMapViewNotification_MapViewDidLoad
                                                          object:theMapView];
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

#pragma mark - Configuration Loading and initialization
- (id) init {
    self = [super init];
    if (self)
    {
        [self LoadConfigData];
    }
    return self;
}

+ (NSBundle *) getEQSBundle
{
    NSBundle *eqsBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"EQSResources" ofType:@"bundle"]];
    if (!eqsBundle)
    {
        eqsBundle = [NSBundle mainBundle];
    }
    return eqsBundle;
}

- (void)LoadConfigData
{
	if (!self.isInitialized)
	{
        // Get our bundle
        NSBundle *eqsBundle = [EQSHelper getEQSBundle];
		NSString *path = [eqsBundle pathForResource:@"EQSConfig" ofType:@"plist"];
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
				self.scaleLevels = [d objectForKey:kEQSConfigKey_ScaleLevels];
				self.defaultScale = [d objectForKey:kEQSConfigKey_DefaultScaleLevel];
                self.basemapPortalItemIDs = [d objectForKey:kEQSConfigKey_BasemapPortalItemIDs];
                self.isInitialized = YES;
			}
		}
		else 
		{
			NSLog(@"Error loading config file: %@", error);
		}
	}
}




#pragma mark - Property accessors
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

#pragma mark - Helper Methods
- (double) getScaleForLevel:(NSUInteger)level
{	
    NSString *key = [NSString stringWithFormat:@"%d", level];
    id scaleVal = [self.scaleLevels objectForKey:key];
    if (scaleVal)
    {
        return [scaleVal doubleValue];
    }
    else
    {
        NSLog(@"Scale level %@ is invalid. Using default of %@.", key, self.defaultScale);
        return [[self.scaleLevels objectForKey:self.defaultScale] doubleValue];
    }
}

- (NSUInteger) getLevelForScale:(double)scale
{
    NSDictionary *sl = self.scaleLevels;

    NSArray *orderedKeys = [sl.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int i1 = [obj1 integerValue];
        int i2 = [obj2 integerValue];
        // We know we want to sort descending, so reverse the ordering...
        return i1 == i2?NSOrderedSame:i1>i2?NSOrderedAscending:NSOrderedDescending;
    }];
    
    NSString *lastLevel = [orderedKeys objectAtIndex:0];
    double lastScale = 0;
    for (NSString *currentLevel in orderedKeys)
    {
        id scaleVal = [sl objectForKey:currentLevel];
        double currentScale = [scaleVal doubleValue];

        if (currentScale > scale &&
            scale >= lastScale)
        {
            NSUInteger retVal = abs(lastLevel.integerValue);
            return retVal;
        }
        else if (currentScale == scale)
        {
            NSUInteger retVal = abs(currentLevel.integerValue);
            return retVal;
        }
        lastScale = currentScale;
        lastLevel = currentLevel;
    }
    NSLog(@"Could not determine level for scale %.4f!!!!", scale);
    return [[orderedKeys lastObject] integerValue];
}

+ (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType
{
    return [[EQSHelper defaultHelper] getPortalItemIDForBasemap:basemapType];
}

- (NSString *) getPortalItemIDForBasemap:(EQSBasemapType)basemapType
{
    NSString *key = [self getBasemapKeyForEnum:basemapType];
    NSAssert1(key != nil, @"Could not figure out which basemap you're after! [%d]", basemapType);
    
    NSString *portalItemID = [self.basemapPortalItemIDs objectForKey:key];
    NSAssert1(portalItemID != nil, @"The basemap hasn't been configured properly! [%@]", key);
    
	return portalItemID;
}

+ (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID
{
	return [[EQSHelper defaultHelper] getBasemapTypeForPortalItemID:portalItemID];
}

- (EQSBasemapType) getBasemapTypeForPortalItemID:(NSString *)portalItemID
{
	NSString *foundKey = nil;
	for (int i=0; i < self.basemapPortalItemIDs.count; i++) {
		NSString *key = [self.basemapPortalItemIDs.allKeys objectAtIndex:i];
		NSString *val = [self.basemapPortalItemIDs objectForKey:key];
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




#pragma mark - Static Helper Methods
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

+ (NSUInteger) getLevelForScale:(double)scale
{
    return [[EQSHelper defaultHelper] getLevelForScale:scale];
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
@end


#pragma mark - Functions
AGSAreaUnits AGSAreaUnitsFromAGSUnits(AGSUnits units)
{
    switch (units) {
        case AGSUnitsMillimeters:
            return AGSAreaUnitsSquareMillimeters;
            break;
        case AGSUnitsCentimeters:
            return AGSAreaUnitsSquareCentimeters;
            break;
        case AGSUnitsDecimeters:
            return AGSAreaUnitsSquareDecimeters;
            break;
        case AGSUnitsMeters:
            return AGSAreaUnitsSquareMeters;
            break;
        case AGSUnitsKilometers:
            return AGSAreaUnitsSquareKilometers;
            break;
            
        case AGSUnitsInches:
            return AGSAreaUnitsSquareInches;
            break;
        case AGSUnitsFeet:
            return AGSAreaUnitsSquareFeet;
            break;
        case AGSUnitsYards:
            return AGSAreaUnitsSquareYards;
            break;
        case AGSUnitsMiles:
            return AGSAreaUnitsSquareMiles;
            break;
            
            
        case AGSUnitsPoints:
            // A point is 1/72 of an inch. Close enough.
            return AGSAreaUnitsSquareInches;
            break;
            
            
        case AGSUnitsNauticalMiles:
            // "Imperial" to "metric"??
            // Nautical mile is exactly 1852m, so least bad choice
            return AGSAreaUnitsHectares;
            break;
        case AGSUnitsDecimalDegrees:
            // See Nautical Miles. Basically, least bad choice.
            return AGSAreaUnitsSquareKilometers;
            break;
            
            
        default:
            // Fall back to S.I.
            return AGSAreaUnitsSquareMeters;
            break;
    }
}

NSString* NSStringFromNSTimeInterval(NSTimeInterval interval)
{
    unsigned long seconds = interval;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    unsigned long hours = minutes / 60;
    minutes %= 60;
    
    if (!hours && !minutes)
    {
        return @"<1 min";
    }

    NSMutableString * result = [NSMutableString string];
    
    if(hours)
        [result appendFormat: @"%ld hours", hours];
    
    if (minutes)
    {
        if (seconds >= 30)
            minutes++;
        [result appendFormat:hours?@" %ld min":@"%ld min", minutes];
        if (minutes != 1)
            [result appendString:@"s"];
    }

    return result;
}

AGSUnits AGSUnitsSmallAlternative(AGSUnits sourceUnit)
{
    switch (sourceUnit) {
        case AGSUnitsMiles:
        case AGSUnitsYards:
            return AGSUnitsFeet;
            break;
        case AGSUnitsFeet:
            return AGSUnitsInches;
        case AGSUnitsInches:
        case AGSUnitsPoints:
            return AGSUnitsPoints;
            
        case AGSUnitsNauticalMiles:
        case AGSUnitsDecimalDegrees:
        case AGSUnitsKilometers:
            return AGSUnitsMeters;
        case AGSUnitsMeters:
        case AGSUnitsDecimeters:
            return AGSUnitsCentimeters;
        case AGSUnitsCentimeters:
        case AGSUnitsMillimeters:
            return AGSUnitsMillimeters;
            
        default:
            return AGSUnitsUnknown;
    }
}

NSString* NSStringFromLengthAndUnit(double length, AGSUnits unit)
{
    AGSUnits displayUnit = unit;
    NSString *formatter = nil;
    if (length < 0.05f)
    {
        displayUnit = AGSUnitsSmallAlternative(unit);
        length = AGSUnitsToUnits(length, unit, displayUnit);
        formatter = @"%.0f %@";
    }
    else
    {
        formatter = @"%.1f %@";
    }
    NSString *unitStr = AGSUnitsAbbreviatedString(displayUnit);
    return [NSString stringWithFormat:formatter, length, unitStr];
}

NSString* NSStringFromAGSDirectionGraphicDistance(AGSDirectionGraphic *graphic)
{
    if (graphic.geometry)
    {
        return NSStringFromLengthAndUnit(graphic.length, AGSUnitsMiles);
    }
    return nil;
}

NSString* NSStringFromAGSDirectionSetDistance(AGSDirectionSet *directions)
{
    if (directions)
    {
        return NSStringFromLengthAndUnit(directions.totalLength, AGSUnitsMiles);
    }
    return nil;
}

NSString* NSStringFromAGSDirectionSetTime(AGSDirectionSet *directions)
{
    if (directions)
    {
        return NSStringFromNSTimeInterval(directions.totalTime * 60);
    }
    return nil;
}

NSString* NSStringFromAGSDirectionGraphicTime(AGSDirectionGraphic *graphic)
{
    if (graphic)
    {
        return NSStringFromNSTimeInterval(graphic.time * 60);
    }
    return nil;
}
