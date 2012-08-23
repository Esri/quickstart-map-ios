//
//  AGSStarterGeoServices.m
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSGeoServices.h"
#import "EQSHelper.h"

#import "AGSPoint+GeneralUtilities.h"

#import <objc/runtime.h>

@implementation AGSMapView (EQSGeoServices)
EQSGeoServices *__agsStarterGeoServices = nil;

- (EQSGeoServices *) geoServices
{
	if (!__agsStarterGeoServices)
	{
		__agsStarterGeoServices = [[EQSGeoServices alloc] init];
	}
	return __agsStarterGeoServices;
}
@end


@implementation NSNotification (EQSDirections)
- (AGSRouteTaskResult *) routeTaskResults
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_FindRoute_RouteTaskResultsKey];
}

- (CLLocation *) geolocation
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_Geolocation_LocationKey];
}

- (NSOperation *) geoServicesOperation
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_WorkerOperationKey];
}

- (NSError *) geoserviceError
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_ErrorKey];
}
@end


//#define kEQSNALocatorURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"
#define kEQSNALocatorURL @"http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
#define kEQSFindAddress_AddressKey @"SingleLine"
#define kEQSFindAddress_ReturnFields @"Loc_name", @"Shape", @"Country", @"Addr_Type", @"Type", @"Match_Addr"
#define kEQSFindAddress_AssociatedAddressKey "address"
#define kEQSFindAddress_AssociatedExtentKey "extent"

#define kEQSFindLocation_AssociatedLocationKey "location"
#define kEQSFindLocation_AssociatedDistanceKey "searchDistance"

#define kEQSMaxDistanceForReverseGeocode 100

#define kEQSRoutingRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"


@interface EQSGeoServices () <AGSLocatorDelegate, AGSRouteTaskDelegate, CLLocationManagerDelegate>
@property (nonatomic, retain) AGSLocator *locator;

@property (nonatomic, retain) AGSRouteTask *routeTask;
@property (nonatomic, retain) AGSRouteTaskParameters *defaultParameters;

@property (nonatomic, retain) AGSPoint *routeStartPoint;
@property (nonatomic, retain) AGSPoint *routeEndPoint;

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation EQSGeoServices
@synthesize locator = _locator;

@synthesize routeTask = _routeTask;
@synthesize defaultParameters = _defaultParameters;

@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeEndPoint = _routeEndPoint;

@synthesize locationManager = _locationManager;

#pragma mark - Initialization
- (id) init
{
	if (self = [super init])
	{
		self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kEQSNALocatorURL]];
        self.locator.delegate = self;
		
		self.routeTask = [AGSRouteTask routeTaskWithURL:[NSURL URLWithString:kEQSRoutingRouteTaskUrl]];
		self.routeTask.delegate = self;
		
		[self.routeTask retrieveDefaultRouteTaskParameters];
	}
	
	return self;
}

- (void) dealloc
{
	self.locator = nil;
	self.routeTask = nil;
}

#pragma mark - Public Methods
- (NSOperation *) findPlaces:(NSString *)singleLineAddress 
{
    return [self findPlaces:singleLineAddress withinEnvelope:nil];
}

- (NSOperation *) findPlaces:(NSString *)singleLineAddress withinEnvelope:(AGSEnvelope *)env
{
	// Tell the service we are providing a single line address.
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:singleLineAddress forKey:kEQSFindAddress_AddressKey];

    if (env)
    {
        NSDictionary *json = [env encodeToJSON];
        NSString *envStr = [json AGSJSONRepresentation];
        NSLog(@"Envelope is: %@", envStr);
        [params setObject:envStr forKey:@"searchExtent"];
    }
    
    // List the fields we want back.
    NSArray *outFields = [NSArray arrayWithObjects:kEQSFindAddress_ReturnFields, nil];
    
    // Set off the request, and get a handle on the processing operation.
    NSOperation *op = [self.locator locationsForAddress:params returnFields:outFields];
    
    // Associate the requested address with the operation - we'll read this later.
    objc_setAssociatedObject(op, kEQSFindAddress_AssociatedAddressKey, singleLineAddress, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEQSFindAddress_AssociatedExtentKey, env, OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (NSOperation *) findAddressFromPoint:(AGSPoint *)mapPoint
{
	return [self pointToAddress:mapPoint withMaxSearchDistance:kEQSMaxDistanceForReverseGeocode];
}

- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint withMaxSearchDistance:(double) searchDistance
{
	NSOperation *op = [self.locator addressForLocation:mapPoint maxSearchDistance:searchDistance];
    
    // Associate the request params with the operation - we'll read these later.
    objc_setAssociatedObject(op, kEQSFindLocation_AssociatedLocationKey, mapPoint, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEQSFindLocation_AssociatedDistanceKey, [NSNumber numberWithDouble:searchDistance], OBJC_ASSOCIATION_RETAIN);
	
    return op;
}

- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)endPoint
{
	AGSRouteTaskParameters *routeTaskParams = [self getParametersToRouteFromStart:startPoint ToStop:endPoint];
	return [self.routeTask solveWithParameters:routeTaskParams];
}

#pragma mark - AGSLocatorDelegate

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{
    @try {
        // Read the stuff we've tagged on to the worker operation
        AGSPoint *location = objc_getAssociatedObject(op, kEQSFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEQSFindLocation_AssociatedDistanceKey);
        
        // Log to the console.
        NSLog(@"Found address at %@\nwithin %@ units of %@:\n%@\n%@", candidate.location, distance,
              [location getWebMercatorAuxSpherePoint], candidate.address, candidate.attributes);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kEQSGeoServicesNotification_WorkerOperationKey,
                                  candidate, kEQSGeoServicesNotification_AddressFromPoint_AddressCandidateKey,
                                  location, kEQSGeoServicesNotification_AddressFromPoint_MapPointKey,
                                  distance, kEQSGeoServicesNotification_AddressFromPoint_DistanceKey,
								  nil];
        
        // And alert our listeners that the operation is complete.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_AddressFromPoint_OK
                                                            object:self
                                                          userInfo:userInfo];
	}
    @finally {
        // Lastly, remove the objects we tagged on to the operation so everything can clean up OK
        objc_setAssociatedObject(op, kEQSFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEQSFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
    @try {
        // Read the stuff we've tagged on to the worker operation
        AGSPoint *location = objc_getAssociatedObject(op, kEQSFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEQSFindLocation_AssociatedDistanceKey);
        
        // Log to the console.
        NSLog(@"Failed to get address within %@ units of %@", distance, location);
        NSLog(@"Error: %@", error);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kEQSGeoServicesNotification_WorkerOperationKey,
                                  error, kEQSGeoServicesNotification_ErrorKey,
                                  location, kEQSGeoServicesNotification_AddressFromPoint_MapPointKey,
                                  distance, kEQSGeoServicesNotification_AddressFromPoint_DistanceKey,
								  nil];
        
        // And alert our listeners that there was an error.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_AddressFromPoint_Error
                                                            object:self
                                                          userInfo:userInfo];
    }
    @finally {
        // Lastly, remove the objects we tagged on to the operation so everything can clean up OK
        objc_setAssociatedObject(op, kEQSFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEQSFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }    
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    @try
    {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kEQSFindAddress_AssociatedAddressKey);
        AGSEnvelope *env = objc_getAssociatedObject(op, kEQSFindAddress_AssociatedExtentKey);
        
        for (AGSAddressCandidate *candidate in candidates) {
            NSLog(@"Found candidate: %@ %@", candidate.addressString, candidate.attributes);
        }

        // Build a dictionary of useful info which listeners to our notification might want.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  op, kEQSGeoServicesNotification_WorkerOperationKey,
                                  candidates, kEQSGeoServicesNotification_PointsFromAddress_LocationCandidatesKey,
                                  address, kEQSGeoServicesNotification_PointsFromAddress_AddressKey,
                                  env, kEQSGeoServicesNotification_PointsFromAddress_ExtentKey,
                                  nil];

        // Post the notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_PointsFromAddress_OK
                                                            object:self
                                                          userInfo:userInfo];
        
    }
    @finally
    {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kEQSFindAddress_AddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEQSFindAddress_AssociatedExtentKey , nil, OBJC_ASSOCIATION_ASSIGN);
    }

}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    @try {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kEQSFindAddress_AssociatedAddressKey);
        AGSEnvelope *env = objc_getAssociatedObject(op, kEQSFindAddress_AssociatedExtentKey);

        // Log to the console.
        NSLog(@"Failed to get locations for Address \"%@\" (within extent %@)", address, env);
        NSLog(@"Error: %@", error);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kEQSGeoServicesNotification_WorkerOperationKey,
                                  error, kEQSGeoServicesNotification_ErrorKey,
                                  address, kEQSGeoServicesNotification_PointsFromAddress_AddressKey,
                                  env, kEQSGeoServicesNotification_PointsFromAddress_ExtentKey,
								  nil];

        // And alert our listeners that there was an error.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_PointsFromAddress_Error
                                                            object:self
                                                          userInfo:userInfo];
    }
    @finally {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kEQSFindAddress_AddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEQSFindAddress_AssociatedExtentKey , nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

#pragma mark - RouteTask Deletegate
- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams
{
	NSLog(@"Got Default Route Task Parameters");
	self.defaultParameters = routeParams;
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error
{
	NSLog(@"Error getting RouteTaskParameters from routing service, using default. Error: %@", error);
	// Something went wrong loading parameters, let's just try with some of our own.
	// They'll be blank, but will hopefully work with the route task.
	self.defaultParameters = [AGSRouteTaskParameters routeTaskParameters];
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult
{
	NSLog(@"Got route results");
	// Reset our internal status.

//	AGSRouteResult *result = [routeTaskResult.routeResults objectAtIndex:0];
        
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:routeTaskResult
														 forKey:kEQSGeoServicesNotification_FindRoute_RouteTaskResultsKey];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_FindRoute_OK
														object:self
													  userInfo:userInfo];
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error
{
    NSLog(@"Failed to get route: %@", error);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_FindRoute_Error
														object:self
													  userInfo:userInfo];
}

#pragma mark - Routing General
- (AGSRouteTaskParameters *) getParametersToRouteFromStart:(AGSPoint *)startPoint ToStop:(AGSPoint *)stopPoint
{
    // Set up and name a couple of stops.
    AGSStopGraphic *firstStop = [AGSStopGraphic graphicWithGeometry:startPoint
                                                             symbol:nil
                                                         attributes:nil
                                               infoTemplateDelegate:nil];
    
    AGSStopGraphic *lastStop = [AGSStopGraphic graphicWithGeometry:stopPoint
                                                            symbol:nil
                                                        attributes:nil
                                              infoTemplateDelegate:nil];
    
    firstStop.name = kEQSRoutingStartPointName;
    lastStop.name = kEQSRoutingEndPointName;
    
    // Add them to the parameters.
    NSArray *routeStops = [NSArray arrayWithObjects:firstStop, lastStop, nil];
    AGSRouteTaskParameters *params = self.defaultParameters;
	if (!params)
	{
		NSLog(@"Couldn't get default Route Task Parameters - using blank");
		params = [AGSRouteTaskParameters routeTaskParameters];
	}
    [params setStopsWithFeatures:routeStops];
    params.returnStopGraphics = YES;
    params.outSpatialReference = [AGSSpatialReference webMercatorSpatialReference];
    
    return params;
}

#pragma mark - Geolocation (GPS)
- (void) findMyLocation
{
    if (!self.locationManager)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 20;
    }
    [self.locationManager startUpdatingLocation];
}

- (BOOL) isGeolocationEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
	NSLog(@"Located me at %.4f,%.4f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:newLocation
														 forKey:kEQSGeoServicesNotification_Geolocation_LocationKey];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_Geolocation_OK
                                                        object:self
                                                      userInfo:userInfo];
//	self.locationManager = nil;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
	NSLog(@"Error getting location: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_Geolocation_Error
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:kEQSGeoServicesNotification_ErrorKey]];
//    self.locationManager = nil;
}
@end