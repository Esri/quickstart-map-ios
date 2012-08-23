//
//  AGSStarterGeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface EQSGeoServices : NSObject
// Geocoding
- (NSOperation *) findPlaces:(NSString *)singleLineAddress;
- (NSOperation *) findPlaces:(NSString *)singleLineAddress withinEnvelope:(AGSEnvelope *)env;

// Reverse Geocoding
- (NSOperation *) findAddressFromPoint:(AGSPoint *)mapPoint;

// Routing
- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)endPoint;

// Geolocation
- (BOOL) isGeolocationEnabled;
- (void) findMyLocation;
@end


#pragma mark - Convenience Categories
@interface AGSMapView (EQSGeoServices)
// Provide a reference to the geoServices instance for an AGSMapView.
- (EQSGeoServices *) geoServices;
@end

@interface NSNotification (EQSGeoServices)
- (AGSRouteTaskResult *) routeTaskResults;
- (CLLocation *) geolocation;
- (NSError *) geoserviceError;
@end



// Notification Definitions - subscribe to these to be notified when GeoServices have completed.
// Each geoservices has an OK and an Error notification. See the keys below for getting information
// about those notifications.
#define kEQSGeoServicesNotification_AddressFromPoint_OK @"EQSGeocodingGetAddressOK"
#define kEQSGeoServicesNotification_AddressFromPoint_Error @"EQSGeocodingGetAddressError"

#define kEQSGeoServicesNotification_PointsFromAddress_OK @"EQSGeocodingAddressSearchOK"
#define kEQSGeoServicesNotification_PointsFromAddress_Error @"EQSGeocodingAddressSearchError"

#define kEQSGeoServicesNotification_FindRoute_OK @"EQSGeoservicesFindRouteOK"
#define kEQSGeoServicesNotification_FindRoute_Error @"EQSGeoservicesFindRouteError"

#define kEQSGeoServicesNotification_Geolocation_OK @"EQSGeolocationSucceeded"
#define kEQSGeoServicesNotification_Geolocation_Error @"EQSGeolocationError"



// Each Notification's userInfo dictionary will contain service-specific values, but some are common
// kEQSGeoServicesNotification_WorkerOperationKey: The NSOperation handling the call.
#define kEQSGeoServicesNotification_WorkerOperationKey @"operation"
// kEQSGeoServicesNotification_ErrorKey: The NSError object in the case a call failed.
#define kEQSGeoServicesNotification_ErrorKey @"error"

#define kEQSGeoServicesNotification_AddressFromPoint_AddressCandidateKey @"candidate"
#define kEQSGeoServicesNotification_AddressFromPoint_MapPointKey @"mapPoint"
#define kEQSGeoServicesNotification_AddressFromPoint_DistanceKey @"distance"

#define kEQSGeoServicesNotification_PointsFromAddress_LocationCandidatesKey @"candidates"
#define kEQSGeoServicesNotification_PointsFromAddress_AddressKey @"address"
#define kEQSGeoServicesNotification_PointsFromAddress_ExtentKey @"searchExtent"

#define kEQSGeoServicesNotification_FindRoute_RouteTaskResultsKey @"routeResult"

#define kEQSGeoServicesNotification_Geolocation_LocationKey @"newLocation"

// Keys to determine properties of the Route Task results.
#define kEQSRoutingStartPointName @"Start Point"
#define kEQSRoutingEndPointName @"End Point"

// Getting address values from the raw AddressFromPoint geoservice result.
#define kEQSAddressCandidateAddressField @"Address"
#define kEQSAddressCandidateCityField @"Admin1"
#define kEQSAddressCandidateStateField @"Admin2"
#define kEQSAddressCandidateZipField @"Postal"