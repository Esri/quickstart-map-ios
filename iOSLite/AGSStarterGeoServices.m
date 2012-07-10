//
//  AGSStarterGeoServices.m
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSStarterGeoServices.h"
#import "EDNLiteHelper.h"
#import "/usr/include/objc/runtime.h"

#define kEDNLiteNALocatorURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"

@interface AGSStarterGeoServices () <AGSLocatorDelegate>
@property (nonatomic, retain) AGSLocator *locator;
@end

@implementation AGSStarterGeoServices
@synthesize locator = _locator;

#pragma mark - Initialization
- (id) init
{
	if (self = [super init])
	{
		self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kEDNLiteNALocatorURL]];
        self.locator.delegate = self;
	}
	
	return self;
}

- (void) dealloc
{
	self.locator = nil;
}

#pragma mark - Public Methods

#define kEDNLiteFindAddress_AddressKey @"SingleLine"
#define kEDNLiteFindAddress_ReturnFields @"Loc_name", @"Shape"
#define kEDNLiteFindAddress_AssociatedAddressKey "address"

#define kEDNLiteFindLocation_AssociatedLocationKey "location"
#define kEDNLiteFindLocation_AssociatedDistanceKey "searchDistance"


- (NSOperation *) addressToPoint:(NSString *)singleLineAddress
{
	// Tell the service we are providing a single line address.
    NSDictionary *params = [NSDictionary dictionaryWithObject:singleLineAddress forKey:kEDNLiteFindAddress_AddressKey];
    // List the fields we want back.
    NSArray *outFields = [NSArray arrayWithObjects:kEDNLiteFindAddress_ReturnFields, nil];
    
    // Set off the request, and get a handle on the processing operation.
    NSOperation *op = [self.locator locationsForAddress:params returnFields:outFields];
    
    // Associate the requested address with the operation - we'll read this later.
    objc_setAssociatedObject(op, kEDNLiteFindAddress_AssociatedAddressKey, singleLineAddress, OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint
{
	return [self pointToAddress:mapPoint withMaxSearchDistance:100];
}

- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint withMaxSearchDistance:(double) searchDistance
{
	NSOperation *op = [self.locator addressForLocation:mapPoint maxSearchDistance:searchDistance];
    
    // Associate the request params with the operation - we'll read these later.
    objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey, mapPoint, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey, [NSNumber numberWithDouble:searchDistance], OBJC_ASSOCIATION_RETAIN);
	
    return op;
}

- (NSOperation *) directionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)fromPoint
{
	return nil;
}

#pragma mark - AGSLocatorDelegate

#define kEDNLiteGeocodingNotification_AddressForPointOK @"EDNLiteGeocodingGetAddressOK"

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{
    @try {
        AGSPoint *location = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey);
        NSLog(@"Found address at %@ within %@ units of %@: %@", candidate.location, distance, 
              [EDNLiteHelper getWebMercatorAuxSpherePointFromPoint:location], candidate.address);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  candidate, kEDNLiteGeocodingNotification_AddressFromPoint_AddressCandidateKey,
								  op, kEDNLiteGeocodingNotification_AddressFromPoint_WorkerOperationKey,
                                  location, kEDNLiteGeocodingNotification_AddressFromPoint_MapPointKey,
								  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_AddressForPointOK
                                                            object:self
                                                          userInfo:userInfo];
	}
    @finally {
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
    @try {
        AGSPoint *location = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey);
        NSLog(@"Failed to get address within %@ units of %@", distance, location);
    }
    @finally {
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }    
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
	
}
@end
