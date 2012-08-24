//
//  EQSGeoServicesNotifications.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#ifndef esriQuickStartApp_EQSGeoServicesNotifications_h
#define esriQuickStartApp_EQSGeoServicesNotifications_h



#pragma mark - Notifications raised by EQSGeoServices objects.
// Notification Definitions - subscribe to these to be notified when GeoServices have completed.
// Each geoservices has an OK and an Error notification. See the keys below for getting information
// about those notifications.
#define kEQSGeoServicesNotification_PointsFromAddress_OK @"EQSGeocodingAddressSearchOK"
#define kEQSGeoServicesNotification_PointsFromAddress_Error @"EQSGeocodingAddressSearchError"

#define kEQSGeoServicesNotification_AddressFromPoint_OK @"EQSGeocodingGetAddressOK"
#define kEQSGeoServicesNotification_AddressFromPoint_Error @"EQSGeocodingGetAddressError"

#define kEQSGeoServicesNotification_FindRoute_OK @"EQSGeoservicesFindRouteOK"
#define kEQSGeoServicesNotification_FindRoute_Error @"EQSGeoservicesFindRouteError"

#define kEQSGeoServicesNotification_Geolocation_OK @"EQSGeolocationSucceeded"
#define kEQSGeoServicesNotification_Geolocation_Error @"EQSGeolocationError"




#pragma mark - Dictionary Keys for reading common values from EQSGeoServices Notification UserInfos

// Each Notification's userInfo dictionary will contain service-specific values, but some are common
// kEQSGeoServicesNotification_WorkerOperationKey: The NSOperation handling the call.
#define kEQSGeoServicesNotification_WorkerOperationKey @"operation"

// kEQSGeoServicesNotification_ErrorKey: The NSError object in the case a call failed.
#define kEQSGeoServicesNotification_ErrorKey @"error"




#pragma mark - Dictionary Keys for reading values from specific EQSGeoServices Notification UserInfos

#define kEQSGeoServicesNotification_PointsFromAddress_LocationCandidatesKey @"candidates"
#define kEQSGeoServicesNotification_PointsFromAddress_AddressKey @"address"
#define kEQSGeoServicesNotification_PointsFromAddress_ExtentKey @"searchExtent"

#define kEQSGeoServicesNotification_AddressFromPoint_AddressCandidateKey @"candidate"
#define kEQSGeoServicesNotification_AddressFromPoint_MapPointKey @"mapPoint"
#define kEQSGeoServicesNotification_AddressFromPoint_DistanceKey @"distance"

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





#pragma mark - Categories to help read information from EQSGeoServices Notifications
@interface NSNotification (EQSGeoServices)
// All notifications include the worker NSOperation
- (NSOperation *) geoServicesOperation;

// Error notifications also include an NSError object.
- (NSError *) geoServicesError;


// Additional values can be retrieved according to geoservice request.

// kEQSGeoServicesNotification_PointsFromAddress_OK
// kEQSGeoServicesNotification_PointsFromAddress_Error
- (NSArray *) findPlacesCandidates;
- (NSString *) findPlacesSearchString;
- (AGSEnvelope *) findPlacesSearchExtent; // optional

// kEQSGeoServicesNotification_AddressFromPoint_OK
// kEQSGeoServicesNotification_AddressFromPoint_Error
- (AGSAddressCandidate *) findAddressCandidate;
- (AGSPoint *) findAddressSearchPoint;
- (double) findAddressSearchDistance;

// kEQSGeoServicesNotification_FindRoute_OK
// kEQSGeoServicesNotification_FindRoute_Error
- (AGSRouteTaskResult *) routeTaskResults;

// kEQSGeoServicesNotification_Geolocation_OK
// kEQSGeoServicesNotification_Geolocation_Error
- (CLLocation *) geolocationResult;
@end
#endif
