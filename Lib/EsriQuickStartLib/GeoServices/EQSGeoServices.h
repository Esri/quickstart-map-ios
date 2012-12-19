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

// Notification Registration
- (void) registerHandler:(id)object forFindDirectionsSuccess:(SEL)successHandler andFailure:(SEL)failureHandler;
@end



// Provide a reference to the geoServices instance for an AGSMapView.
@interface AGSMapView (EQSGeoServices)
- (EQSGeoServices *) geoServices;
@end



// Provide a way to get an envelope for a geocode result. Note, this may return nil.
@interface AGSAddressCandidate (EQSGeoServices)
@property (readonly, nonatomic) AGSEnvelope *placeExtent;
@end
