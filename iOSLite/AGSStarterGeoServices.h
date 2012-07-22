//
//  AGSStarterGeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#define kEDNLiteGeocodingNotification_AddressFromPoint_OK @"EDNLiteGeocodingGetAddressOK"
#define kEDNLiteGeocodingNotification_AddressFromPoint_Error @"EDNLiteGeocodingGetAddressError"

#define kEDNLiteGeocodingNotification_PointsFromAddress_OK @"EDNLiteGeocodingAddressSearchOK"
#define kEDNLiteGeocodingNotification_PointsFromAddress_Error @"EDNLiteGeocodingAddressSearchError"

#define kEDNLiteGeocodingNotification_WorkerOperationKey @"operation"
#define kEDNLiteGeocodingNotification_ErrorKey "error"

#define kEDNLiteGeocodingNotification_AddressFromPoint_AddressCandidateKey @"candidate"
#define kEDNLiteGeocodingNotification_AddressFromPoint_MapPointKey @"mapPoint"
#define kEDNLiteGeocodingNotification_AddressFromPoint_DistanceKey @"distance"

#define kEDNLiteGeocodingNotification_PointsFromAddress_LocationCandidatesKey @"candidates"
#define kEDNLiteGeocodingNotification_PointsFromAddress_AddressKey @"address"
#define kEDNLiteGeocodingNotification_PointsFromAddress_ExtentKey @"searchExtent"

@interface AGSStarterGeoServices : NSObject
- (NSOperation *) addressToPoint:(NSString *)singleLineAddress;
- (NSOperation *) addressToPoint:(NSString *)singleLineAddress forEnvelope:(AGSEnvelope *)env;
- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint;
- (NSOperation *) directionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)fromPoint;
@end
