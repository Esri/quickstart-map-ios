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

//#define kEDNLiteNALocatorURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"
#define kEDNLiteNALocatorURL @"http://geocodedev.arcgis.com/arcgis/rest/services/World/GeocodeServer"
#define kEDNLiteFindAddress_AddressKey @"SingleLine"
#define kEDNLiteFindAddress_ReturnFields @"Loc_name", @"Shape"
#define kEDNLiteFindAddress_AssociatedAddressKey "address"
#define kEDNLiteFindAddress_AssociatedExtentKey "extent"

#define kEDNLiteFindLocation_AssociatedLocationKey "location"
#define kEDNLiteFindLocation_AssociatedDistanceKey "searchDistance"

#define kEDNLiteMaxDistanceForReverseGeocode 100

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
- (NSOperation *) addressToPoint:(NSString *)singleLineAddress 
{
    return [self addressToPoint:singleLineAddress forEnvelope:nil];
}

- (NSOperation *) addressToPoint:(NSString *)singleLineAddress forEnvelope:(AGSEnvelope *)env
{
	// Tell the service we are providing a single line address.
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:singleLineAddress forKey:kEDNLiteFindAddress_AddressKey];

    if (env)
    {
        NSDictionary *json = [env encodeToJSON];
        NSString *envStr = [json AGSJSONRepresentation];
        NSLog(@"Envelope is: %@", envStr);    
        [params setObject:envStr forKey:@"searchExtent"];
    }
    
    // List the fields we want back.
    NSArray *outFields = [NSArray arrayWithObjects:kEDNLiteFindAddress_ReturnFields, nil];
    
    // Set off the request, and get a handle on the processing operation.
    NSOperation *op = [self.locator locationsForAddress:params returnFields:outFields];
    
    // Associate the requested address with the operation - we'll read this later.
    objc_setAssociatedObject(op, kEDNLiteFindAddress_AssociatedAddressKey, singleLineAddress, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEDNLiteFindAddress_AssociatedExtentKey, env, OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint
{
	return [self pointToAddress:mapPoint withMaxSearchDistance:kEDNLiteMaxDistanceForReverseGeocode];
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

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{
    @try {
        // Read the stuff we've tagged on to the worker operation
        AGSPoint *location = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey);
        
        // Log to the console.
        NSLog(@"Found address at %@ within %@ units of %@: %@", candidate.location, distance, 
              [EDNLiteHelper getWebMercatorAuxSpherePointFromPoint:location], candidate.address);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kEDNLiteGeocodingNotification_WorkerOperationKey,
                                  candidate, kEDNLiteGeocodingNotification_AddressFromPoint_AddressCandidateKey,
                                  location, kEDNLiteGeocodingNotification_AddressFromPoint_MapPointKey,
                                  distance, kEDNLiteGeocodingNotification_AddressFromPoint_DistanceKey,
								  nil];
        
        // And alert our listeners that the operation is complete.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_AddressFromPoint_OK
                                                            object:self
                                                          userInfo:userInfo];
	}
    @finally {
        // Lastly, remove the objects we tagged on to the operation so everything can clean up OK
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
    @try {
        // Read the stuff we've tagged on to the worker operation
        AGSPoint *location = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey);
        
        // Log to the console.
        NSLog(@"Failed to get address within %@ units of %@", distance, location);
        NSLog(@"Error: %@", error);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kEDNLiteGeocodingNotification_WorkerOperationKey,
                                  error, kEDNLiteGeocodingNotification_ErrorKey,
                                  location, kEDNLiteGeocodingNotification_AddressFromPoint_MapPointKey,
                                  distance, kEDNLiteGeocodingNotification_AddressFromPoint_DistanceKey,
								  nil];
        
        // And alert our listeners that there was an error.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_AddressFromPoint_Error
                                                            object:self
                                                          userInfo:userInfo];
    }
    @finally {
        // Lastly, remove the objects we tagged on to the operation so everything can clean up OK
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }    
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    @try
    {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kEDNLiteFindAddress_AssociatedAddressKey);
        AGSEnvelope *env = objc_getAssociatedObject(op, kEDNLiteFindAddress_AssociatedExtentKey);
        
        // Build a dictionary of useful info which listeners to our notification might want.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  op, kEDNLiteGeocodingNotification_WorkerOperationKey,
                                  candidates, kEDNLiteGeocodingNotification_PointsFromAddress_LocationCandidatesKey,
                                  address, kEDNLiteGeocodingNotification_PointsFromAddress_AddressKey,
                                  env, kEDNLiteGeocodingNotification_PointsFromAddress_ExtentKey,
                                  nil];

        // Post the notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_PointsFromAddress_OK
                                                            object:self
                                                          userInfo:userInfo];
        
    }
    @finally
    {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kEDNLiteFindAddress_AddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteFindAddress_AssociatedExtentKey , nil, OBJC_ASSOCIATION_ASSIGN);
    }

}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    @try {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kEDNLiteFindAddress_AssociatedAddressKey);
        AGSEnvelope *env = objc_getAssociatedObject(op, kEDNLiteFindAddress_AssociatedExtentKey);

        // Log to the console.
        NSLog(@"Failed to get locations for Address \"%@\" (within extent %@)", address, env);
        NSLog(@"Error: %@", error);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kEDNLiteGeocodingNotification_WorkerOperationKey,
                                  error, kEDNLiteGeocodingNotification_ErrorKey,
                                  address, kEDNLiteGeocodingNotification_PointsFromAddress_AddressKey,
                                  env, kEDNLiteGeocodingNotification_PointsFromAddress_ExtentKey,
								  nil];

        // And alert our listeners that there was an error.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_PointsFromAddress_Error
                                                            object:self
                                                          userInfo:userInfo];
    }
    @finally {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kEDNLiteFindAddress_AddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteFindAddress_AssociatedExtentKey , nil, OBJC_ASSOCIATION_ASSIGN);
    }
}
@end
