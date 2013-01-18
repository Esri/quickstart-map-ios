//
//  AGSStarterGeoServices.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSGeoServicesNotifications.h"

@class EQSGeoServices;

// Provide a reference to the geoServices instance for an AGSMapView.
@interface AGSMapView (EQSGeoServices)
@property (nonatomic, readonly) EQSGeoServices *geoServices;
@end

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
@property (nonatomic, readonly) BOOL geolocationEnabled;
- (void) findMyLocation;

// Notification Registration
- (void) registerHandler:(id)object forFindDirectionsSuccess:(SEL)successHandler andFailure:(SEL)failureHandler;
@end





@interface AGSLocatorFindResult (EQSGeoServices)
@property (nonatomic, readonly) CGFloat score;
@property (nonatomic, readonly) AGSPoint *location;
@end