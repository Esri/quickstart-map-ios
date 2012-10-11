//
//  AGSStarterGeoServices.h
//  EsriQuickStartApp
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
- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint to:(AGSPoint *)endPoint;
- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint named:(NSString *)startPointName
                                  to:(AGSPoint *)endPoint named:(NSString *)endPointName;

// Geolocation
- (BOOL) isGeolocationEnabled;
- (void) findMyLocation;
@end



// Provide a reference to the geoServices instance for an AGSMapView.
@interface AGSMapView (EQSGeoServices)
- (EQSGeoServices *) geoServices;
@end



//@interface AGSAddressCandidate (EQSGeoServices)
//- (AGSPoint *) displayPoint;
//@end

//#import <objc/runtime.h>

//@implementation AGSAddressCandidate (EQSGeoServices)
//- (AGSPoint *) displayPoint
//{
//    return objc_getAssociatedObject(self, @"DisplayPoint");
//}
//@end
