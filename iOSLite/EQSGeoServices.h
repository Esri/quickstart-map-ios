//
//  AGSStarterGeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSGeoServicesNotifications.h"

@interface EQSGeoServices : NSObject
// Geocoding
- (NSOperation *) findPlaces:(NSString *)singleLineAddress;
- (NSOperation *) findPlaces:(NSString *)singleLineAddress withinEnvelope:(AGSEnvelope *)env;

// Reverse Geocoding
- (NSOperation *) findAddressFromPoint:(AGSPoint *)mapPoint;

// Routing
- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)endPoint;
- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint Named:(NSString *)startPointName
                                  To:(AGSPoint *)endPoint Named:(NSString *)endPointName;

// Geolocation
- (BOOL) isGeolocationEnabled;
- (void) findMyLocation;
@end



// Provide a reference to the geoServices instance for an AGSMapView.
@interface AGSMapView (EQSGeoServices)
- (EQSGeoServices *) geoServices;
@end

