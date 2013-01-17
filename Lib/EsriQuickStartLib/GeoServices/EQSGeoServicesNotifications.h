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
#define kEQSGeoServicesNotification_FindPlaces_OK @"EQSGeocodingFindPlacesOK"
#define kEQSGeoServicesNotification_FindPlaces_Error @"EQSGeocodingFindPlacesError"

#define kEQSGeoServicesNotification_AddressFromPoint_OK @"EQSGeocodingGetAddressOK"
#define kEQSGeoServicesNotification_AddressFromPoint_Error @"EQSGeocodingGetAddressError"

#define kEQSGeoServicesNotification_FindDirections_OK @"EQSGeoservicesFindRouteOK"
#define kEQSGeoServicesNotification_FindDirections_Error @"EQSGeoservicesFindRouteError"

#define kEQSGeoServicesNotification_Geolocation_OK @"EQSGeolocationSucceeded"
#define kEQSGeoServicesNotification_Geolocation_Error @"EQSGeolocationError"


#pragma mark - Keys to read attributes from returned AGSAddressCandidates
// Getting address values from the raw AddressFromPoint geoservice result.
#define kEQSAddressCandidateAddressField @"Address"
#define kEQSAddressCandidateCityField @"City"
#define kEQSAddressCandidateStateField @"Region"
#define kEQSAddressCandidateZipField @"Postal"


#pragma mark - Categories to help read information from EQSGeoServices Notifications
@interface NSNotification (EQSGeoServices)
// All notifications include the worker NSOperation
- (NSOperation *) geoServicesOperation;

// Error notifications also include an NSError object.
- (NSError *) geoServicesError;
@end

// Additional values can be retrieved according to geoservice request.
@interface NSNotification (EQSGeoServices_FindPlaces)
// kEQSGeoServicesNotification_FindPlace_OK
// kEQSGeoServicesNotification_FindPlace_Error
- (NSArray *) findPlacesCandidates;
- (NSArray *) findPlacesCandidatesSortedByScore;
- (NSString *) findPlacesSearchString;
- (AGSEnvelope *) findPlacesSearchExtent; // optional
@end

@interface NSNotification (EQSGeoServices_FindAddress)
// kEQSGeoServicesNotification_AddressFromPoint_OK
// kEQSGeoServicesNotification_AddressFromPoint_Error
- (AGSAddressCandidate *) findAddressCandidate;
- (AGSPoint *) findAddressSearchPoint;
- (double) findAddressSearchDistance;
@end

@interface NSNotification (EQSGeoServices_FindDirections)
// kEQSGeoServicesNotification_FindDirections_OK
// kEQSGeoServicesNotification_FindDirections_Error
- (AGSRouteTaskResult *) routeTaskResults;
@end

@interface NSNotification (EQSGeoServices_Geolocate)
// kEQSGeoServicesNotification_Geolocation_OK
// kEQSGeoServicesNotification_Geolocation_Error
- (CLLocation *) geolocationResult;
- (AGSPoint *) geolocationMapPoint;
@end
#endif
