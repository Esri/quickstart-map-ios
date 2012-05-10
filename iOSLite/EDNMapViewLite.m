//
//  EDNMapViewLite.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNMapViewLite.h"

@interface EDNMapViewLite()<AGSPortalDelegate, AGSWebMapDelegate>
@end

@implementation EDNMapViewLite
NSDictionary * __scales = nil;
NSString * __defaultScaleLevel = @"11";

- (void)LoadConfigData
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
            __scales = [d objectForKey:@"DefaultScaleLevels"];
        }
    }
    else 
    {
        NSLog(@"Error loading config file: %@", error);
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
//        self.portal = [[AGSPortal alloc] initWithURL:[NSURL URLWithString:@"http://www.arcgis.com"] credential:nil];
//        self.portal.delegate = self;
        
        self.wrapAround = YES;
        
        [self LoadConfigData];
    }
    return self;
}

- (void) dealloc
{
//    self.portal = nil;
}

- (double) getScaleForLevel:(NSUInteger)level
{
    NSString *key = [NSString stringWithFormat:@"%d", level];
    id scaleVal = [__scales objectForKey:key];
    if (scaleVal)
    {
        return [scaleVal doubleValue];
    }
    else
    {
        NSLog(@"Scale level %@ is invalid. Using default of %@.", key, __defaultScaleLevel);
        return [[__scales objectForKey:__defaultScaleLevel] doubleValue];
    }
}

- (AGSPoint *) getWebMercatorAuxSpherePointFromWGS84Point:(AGSPoint *)wgs84Point {
    @try
    {
    return (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:wgs84Point 
                                                               toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];    
    }
    @catch (NSException *e) {
        NSLog(@"Error getting Web Mercator Point from %@: %@",wgs84Point, e); 
    }
}

- (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Long:(double) longitude
{
    // Ensure we're passed sensible values for lat and long
    NSAssert1((-90 <= latitude) && (latitude <= 90), @"Latitude %f must be between -90 and 90 degrees", latitude);
    
    AGSPoint *wgs84CenterPt = [AGSPoint pointWithX:longitude y:latitude spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    return [self getWebMercatorAuxSpherePointFromWGS84Point:wgs84CenterPt];
}

// PUBLIC
- (void) zoomToLat:(double) latitude Long:(double) longitude withScaleLevel:(int)scaleLevel
{
    AGSPoint *webMercatorCenterPt = [self getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
    double scale = [self getScaleForLevel:scaleLevel];
    
    [self zoomToScale:scale withCenterPoint:webMercatorCenterPt animated:YES];    
}

- (void) centerAtLat:(double) latitude Long:(double) longitude
{
    AGSPoint *p = [self getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    [self centerAtPoint:p animated:YES];
}
@end
