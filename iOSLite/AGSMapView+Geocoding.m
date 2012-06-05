//
//  AGSMapView+Geocoding.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Geocoding.h"

@interface AGSMapView ()<AGSLocatorDelegate>
@end

@implementation AGSMapView (Geocoding)
#define kEDNLiteGeocoderServiceURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"

AGSLocator * __ednLiteLocator;

- (void) findAddress:(NSString *)singleLineAddress
{
    [self __ednLiteInitLocator];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:singleLineAddress forKey:@"SingleLine"];
    NSArray *outFields = [NSArray arrayWithObjects:@"Loc_name", @"Shape", nil];
    
    [__ednLiteLocator locationsForAddress:params returnFields:outFields];
}

- (void) getAddressForLat:(double)latitude Lon:(double)longitude
{
    
}

- (void) __ednLiteInitLocator
{
    if (!__ednLiteLocator)
    {
        __ednLiteLocator = [AGSLocator locatorWithURL:[NSURL URLWithString:kEDNLiteGeocoderServiceURL]];
        __ednLiteLocator.delegate = self;
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{

}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    
}
@end
