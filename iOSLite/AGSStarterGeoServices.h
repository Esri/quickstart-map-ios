//
//  AGSStarterGeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#define kEDNLiteGeocodingNotification_AddressFromPointOK @"EDNLiteGeocodingGetAddressOK"
#define kEDNLiteGeocodingNotification_AddressFromPointError @"EDNLiteGeocodingGetAddressError"

#define kEDNLiteGeocodingNotification_AddressFromPoint_WorkerOperationKey @"operation"
#define kEDNLiteGeocodingNotification_AddressFromPoint_AddressCandidateKey @"candidate"
#define kEDNLiteGeocodingNotification_AddressFromPoint_MapPointKey @"mapPoint"

@interface AGSStarterGeoServices : NSObject
- (id) init;
- (NSOperation *) addressToPoint:(NSString *)singleLineAddress;
- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint;
- (NSOperation *) directionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)fromPoint;
@end
