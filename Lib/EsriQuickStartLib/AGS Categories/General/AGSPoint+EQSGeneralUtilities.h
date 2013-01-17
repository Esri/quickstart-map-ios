//
//  AGSPoint+GeneralUtilities.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSPoint (EQSGeneralUtilities)
// Convenience function to return a new AGSPoint given a Lat and Lon.
+ (AGSPoint *) pointFromLat:(double)latitude lon:(double)longitude;

// Read the Lat and Lon values from any point, regardless of its internal spatial reference.
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

// Convenience functions for translating to Web Mercator Auxiliary Sphere spatial reference
//+ (AGSPoint *) getWebMercatorAuxSpherePointFromLat:(double) latitude Lon:(double) longitude;
- (AGSPoint *) getWebMercatorAuxSpherePoint;
- (AGSPoint *) getWGS84Point;
@end
