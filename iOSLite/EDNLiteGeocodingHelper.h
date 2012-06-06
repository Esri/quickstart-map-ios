//
//  EDNLiteGeocodingHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

#define kEDNLiteGeocodingNotification_AddressSearchOK @"EDNLiteGeocodingAddressSearchOK"
#define kEDNLiteGeocodingNotification_AddressSearchError @"EDNLiteGeocodingAddressSearchError"

#define kEDNLiteGeocodingResultAddressCandidates @"addressCandidates"
#define kEDNLiteGeocodingResultAddressQuery @"addressQuery"
#define kEDNLiteGeocodingResultError @"error"

@interface EDNLiteGeocodingHelper : NSObject
+ (EDNLiteGeocodingHelper *) ednLiteGeocodingHelper;
+ (EDNLiteGeocodingHelper *) ednLiteGeocodingHelperForMapView:(AGSMapView *)mapView;

- (NSOperation *) findAddress:(NSString *)address;
- (NSOperation *) getAddressForLocation:(AGSPoint *)location WithSearchDistance:(double)searchDistance;

@property (nonatomic, retain, readonly) AGSGraphicsLayer *resultsGraphicsLayer;
@property (nonatomic, retain, readonly) AGSLocator *locator;
@property (nonatomic, assign) id<AGSLocatorDelegate> delegate;
@end
