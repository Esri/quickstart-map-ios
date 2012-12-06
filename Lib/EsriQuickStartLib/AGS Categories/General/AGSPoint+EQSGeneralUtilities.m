//
//  AGSPoint+GeneralUtilities.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSPoint+EQSGeneralUtilities.h"
#import "EQSHelper.h"

@implementation AGSPoint (EQSGeneralUtilities)
+ (AGSPoint *) pointFromLat:(double)latitude lon:(double)longitude
{
    // Ensure we're passed sensible values for lat and long
    NSAssert1((-90 <= latitude) && (latitude <= 90), @"Latitude %f must be between -90 and 90 degrees", latitude);
    
    AGSPoint *wgs84CenterPt = [AGSPoint pointWithX:longitude y:latitude spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    return [wgs84CenterPt getWebMercatorAuxSpherePoint];
}

- (double) latitude
{
	AGSPoint *geoPt = [self getWGS84Point];
	return geoPt.y;
}

- (double) longitude
{
	AGSPoint *geoPt = [self getWGS84Point];
	return geoPt.x;
}

#pragma mark - Spatial Reference Shortcuts
- (AGSPoint *) getWebMercatorAuxSpherePoint
{
    if ([self.spatialReference isEqualToSpatialReference:[AGSSpatialReference webMercatorSpatialReference]])
    {
        return self;
    }
    else
    {
        @try
        {
            return (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:self
                                                                       toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
        }
        @catch (NSException *e) {
            NSLog(@"Error getting Web Mercator Point from %@: %@",self, e);
        }
    }
}

- (AGSPoint *) getWGS84Point
{
    if ([self.spatialReference isEqualToSpatialReference:[AGSSpatialReference wgs84SpatialReference]])
    {
        return self;
    }
    else
    {
        @try
        {
            return (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:self
                                                                       toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
        }
        @catch (NSException *e) {
            NSLog(@"Error getting WGS84 Point from %@: %@",self, e);
        }
    }
}
@end
