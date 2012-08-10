//
//  AGSStarterGeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#define kEDNLiteGeoServicesNotification_AddressFromPoint_OK @"EDNLiteGeocodingGetAddressOK"
#define kEDNLiteGeoServicesNotification_AddressFromPoint_Error @"EDNLiteGeocodingGetAddressError"

#define kEDNLiteGeoServicesNotification_PointsFromAddress_OK @"EDNLiteGeocodingAddressSearchOK"
#define kEDNLiteGeoServicesNotification_PointsFromAddress_Error @"EDNLiteGeocodingAddressSearchError"

#define kEDNLiteGeoServicesNotification_FindRoute_OK @"EDNLiteGeoservicesFindRouteOK"
#define kEDNLiteGeoServicesNotification_FindRoute_Error @"EDNLiteGeoservicesFindRouteError"

#define kEDNLiteGeoServicesNotification_WorkerOperationKey @"operation"
#define kEDNLiteGeoServicesNotification_ErrorKey @"error"

#define kEDNLiteGeoServicesNotification_AddressFromPoint_AddressCandidateKey @"candidate"
#define kEDNLiteGeoServicesNotification_AddressFromPoint_MapPointKey @"mapPoint"
#define kEDNLiteGeoServicesNotification_AddressFromPoint_DistanceKey @"distance"

#define kEDNLiteGeoServicesNotification_PointsFromAddress_LocationCandidatesKey @"candidates"
#define kEDNLiteGeoServicesNotification_PointsFromAddress_AddressKey @"address"
#define kEDNLiteGeoServicesNotification_PointsFromAddress_ExtentKey @"searchExtent"

#define kEDNLiteGeoServicesNotification_FindRoute_RouteTaskResultsKey @"routeResult"

// Keys to determine properties of the Route Task results.
#define kEDNLiteRoutingStartPointName @"Start Point"
#define kEDNLiteRoutingEndPointName @"End Point"

#define kEDNLiteAddressCandidateAddressField @"Address"
#define kEDNLiteAddressCandidateCityField @"Admin1"
#define kEDNLiteAddressCandidateStateField @"Admin2"
#define kEDNLiteAddressCandidateZipField @"Postal"

@interface AGSStarterGeoServices : NSObject
// Geocoding
- (NSOperation *) getPointFromAddress:(NSString *)singleLineAddress;
- (NSOperation *) getPointFromAddress:(NSString *)singleLineAddress withinEnvelope:(AGSEnvelope *)env;
// Reverse Geocoding
- (NSOperation *) getAddressFromPoint:(AGSPoint *)mapPoint;
// Routing
- (NSOperation *) getDirectionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)fromPoint;
@end
