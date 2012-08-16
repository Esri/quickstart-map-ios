//
//  AGSStarterGeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

// Notification Definitions - subscribe to these to be notified when GeoServices have completed.
// Each geoservices has an OK and an Error notification. See the keys below for getting information
// about those notifications.
#define kSTXGeoServicesNotification_AddressFromPoint_OK @"STXGeocodingGetAddressOK"
#define kSTXGeoServicesNotification_AddressFromPoint_Error @"STXGeocodingGetAddressError"

#define kSTXGeoServicesNotification_PointsFromAddress_OK @"STXGeocodingAddressSearchOK"
#define kSTXGeoServicesNotification_PointsFromAddress_Error @"STXGeocodingAddressSearchError"

#define kSTXGeoServicesNotification_FindRoute_OK @"STXGeoservicesFindRouteOK"
#define kSTXGeoServicesNotification_FindRoute_Error @"STXGeoservicesFindRouteError"

// Each Notification's userInfo dictionary will contain service-specific values, but some are common
// kSTXGeoServicesNotification_WorkerOperationKey: The NSOperation handling the call.
#define kSTXGeoServicesNotification_WorkerOperationKey @"operation"
// kSTXGeoServicesNotification_ErrorKey: The NSError object in the case a call failed.
#define kSTXGeoServicesNotification_ErrorKey @"error"

#define kSTXGeoServicesNotification_AddressFromPoint_AddressCandidateKey @"candidate"
#define kSTXGeoServicesNotification_AddressFromPoint_MapPointKey @"mapPoint"
#define kSTXGeoServicesNotification_AddressFromPoint_DistanceKey @"distance"

#define kSTXGeoServicesNotification_PointsFromAddress_LocationCandidatesKey @"candidates"
#define kSTXGeoServicesNotification_PointsFromAddress_AddressKey @"address"
#define kSTXGeoServicesNotification_PointsFromAddress_ExtentKey @"searchExtent"

#define kSTXGeoServicesNotification_FindRoute_RouteTaskResultsKey @"routeResult"

// Keys to determine properties of the Route Task results.
#define kSTXRoutingStartPointName @"Start Point"
#define kSTXRoutingEndPointName @"End Point"

// Getting address values from the raw AddressFromPoint geoservice result.
#define kSTXAddressCandidateAddressField @"Address"
#define kSTXAddressCandidateCityField @"Admin1"
#define kSTXAddressCandidateStateField @"Admin2"
#define kSTXAddressCandidateZipField @"Postal"

@interface STXGeoServices : NSObject
// Geocoding
- (NSOperation *) getPointFromAddress:(NSString *)singleLineAddress;
- (NSOperation *) getPointFromAddress:(NSString *)singleLineAddress withinEnvelope:(AGSEnvelope *)env;
// Reverse Geocoding
- (NSOperation *) getAddressFromPoint:(AGSPoint *)mapPoint;
// Routing
- (NSOperation *) getDirectionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)fromPoint;
@end
