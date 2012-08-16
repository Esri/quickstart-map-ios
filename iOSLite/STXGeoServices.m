//
//  AGSStarterGeoServices.m
//  iOSLite
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "STXGeoServices.h"
#import "STXHelper.h"
#import <objc/runtime.h>

//#define kSTXNALocatorURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"
#define kSTXNALocatorURL @"http://geocodedev.arcgis.com/arcgis/rest/services/World/GeocodeServer"
#define kSTXFindAddress_AddressKey @"SingleLine"
#define kSTXFindAddress_ReturnFields @"Loc_name", @"Shape"
#define kSTXFindAddress_AssociatedAddressKey "address"
#define kSTXFindAddress_AssociatedExtentKey "extent"

#define kSTXFindLocation_AssociatedLocationKey "location"
#define kSTXFindLocation_AssociatedDistanceKey "searchDistance"

#define kSTXMaxDistanceForReverseGeocode 100

#define kSTXRoutingRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"


@interface STXGeoServices () <AGSLocatorDelegate, AGSRouteTaskDelegate>
@property (nonatomic, retain) AGSLocator *locator;

@property (nonatomic, retain) AGSRouteTask *routeTask;
@property (nonatomic, retain) AGSRouteTaskParameters *defaultParameters;

@property (nonatomic, retain) AGSPoint *routeStartPoint;
@property (nonatomic, retain) AGSPoint *routeEndPoint;

@property (nonatomic, retain) NSNumber *propertyTest;
@end

@implementation STXGeoServices
@synthesize locator = _locator;

@synthesize routeTask = _routeTask;
@synthesize defaultParameters = _defaultParameters;

@synthesize routeStartPoint = _routeStartPoint;
@synthesize routeEndPoint = _routeEndPoint;

#pragma mark - Initialization
- (id) init
{
	if (self = [super init])
	{
		self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kSTXNALocatorURL]];
        self.locator.delegate = self;
		
		self.routeTask = [AGSRouteTask routeTaskWithURL:[NSURL URLWithString:kSTXRoutingRouteTaskUrl]];
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
- (NSOperation *) getPointFromAddress:(NSString *)singleLineAddress 
{
    return [self getPointFromAddress:singleLineAddress withinEnvelope:nil];
}

- (NSOperation *) getPointFromAddress:(NSString *)singleLineAddress withinEnvelope:(AGSEnvelope *)env
{
	// Tell the service we are providing a single line address.
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:singleLineAddress forKey:kSTXFindAddress_AddressKey];

    if (env)
    {
        NSDictionary *json = [env encodeToJSON];
        NSString *envStr = [json AGSJSONRepresentation];
        NSLog(@"Envelope is: %@", envStr);
        [params setObject:envStr forKey:@"searchExtent"];
    }
    
    // List the fields we want back.
    NSArray *outFields = [NSArray arrayWithObjects:kSTXFindAddress_ReturnFields, nil];
    
    // Set off the request, and get a handle on the processing operation.
    NSOperation *op = [self.locator locationsForAddress:params returnFields:outFields];
    
    // Associate the requested address with the operation - we'll read this later.
    objc_setAssociatedObject(op, kSTXFindAddress_AssociatedAddressKey, singleLineAddress, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kSTXFindAddress_AssociatedExtentKey, env, OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (NSOperation *) getAddressFromPoint:(AGSPoint *)mapPoint
{
	return [self pointToAddress:mapPoint withMaxSearchDistance:kSTXMaxDistanceForReverseGeocode];
}

- (NSOperation *) pointToAddress:(AGSPoint *)mapPoint withMaxSearchDistance:(double) searchDistance
{
	NSOperation *op = [self.locator addressForLocation:mapPoint maxSearchDistance:searchDistance];
    
    // Associate the request params with the operation - we'll read these later.
    objc_setAssociatedObject(op, kSTXFindLocation_AssociatedLocationKey, mapPoint, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kSTXFindLocation_AssociatedDistanceKey, [NSNumber numberWithDouble:searchDistance], OBJC_ASSOCIATION_RETAIN);
	
    return op;
}

- (NSOperation *) getDirectionsFrom:(AGSPoint *)startPoint To:(AGSPoint *)endPoint
{
	AGSRouteTaskParameters *routeTaskParams = [self getParametersToRouteFromStart:startPoint ToStop:endPoint];
	return [self.routeTask solveWithParameters:routeTaskParams];
}

#pragma mark - AGSLocatorDelegate

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{
    @try {
        // Read the stuff we've tagged on to the worker operation
        AGSPoint *location = objc_getAssociatedObject(op, kSTXFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kSTXFindLocation_AssociatedDistanceKey);
        
        // Log to the console.
        NSLog(@"Found address at %@ within %@ units of %@: %@", candidate.location, distance, 
              [STXHelper getWebMercatorAuxSpherePointFromPoint:location], candidate.address);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kSTXGeoServicesNotification_WorkerOperationKey,
                                  candidate, kSTXGeoServicesNotification_AddressFromPoint_AddressCandidateKey,
                                  location, kSTXGeoServicesNotification_AddressFromPoint_MapPointKey,
                                  distance, kSTXGeoServicesNotification_AddressFromPoint_DistanceKey,
								  nil];
        
        // And alert our listeners that the operation is complete.
        [[NSNotificationCenter defaultCenter] postNotificationName:kSTXGeoServicesNotification_AddressFromPoint_OK
                                                            object:self
                                                          userInfo:userInfo];
	}
    @finally {
        // Lastly, remove the objects we tagged on to the operation so everything can clean up OK
        objc_setAssociatedObject(op, kSTXFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kSTXFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
    @try {
        // Read the stuff we've tagged on to the worker operation
        AGSPoint *location = objc_getAssociatedObject(op, kSTXFindLocation_AssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kSTXFindLocation_AssociatedDistanceKey);
        
        // Log to the console.
        NSLog(@"Failed to get address within %@ units of %@", distance, location);
        NSLog(@"Error: %@", error);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kSTXGeoServicesNotification_WorkerOperationKey,
                                  error, kSTXGeoServicesNotification_ErrorKey,
                                  location, kSTXGeoServicesNotification_AddressFromPoint_MapPointKey,
                                  distance, kSTXGeoServicesNotification_AddressFromPoint_DistanceKey,
								  nil];
        
        // And alert our listeners that there was an error.
        [[NSNotificationCenter defaultCenter] postNotificationName:kSTXGeoServicesNotification_AddressFromPoint_Error
                                                            object:self
                                                          userInfo:userInfo];
    }
    @finally {
        // Lastly, remove the objects we tagged on to the operation so everything can clean up OK
        objc_setAssociatedObject(op, kSTXFindLocation_AssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kSTXFindLocation_AssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }    
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    @try
    {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kSTXFindAddress_AssociatedAddressKey);
        AGSEnvelope *env = objc_getAssociatedObject(op, kSTXFindAddress_AssociatedExtentKey);
        
        // Build a dictionary of useful info which listeners to our notification might want.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  op, kSTXGeoServicesNotification_WorkerOperationKey,
                                  candidates, kSTXGeoServicesNotification_PointsFromAddress_LocationCandidatesKey,
                                  address, kSTXGeoServicesNotification_PointsFromAddress_AddressKey,
                                  env, kSTXGeoServicesNotification_PointsFromAddress_ExtentKey,
                                  nil];

        // Post the notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:kSTXGeoServicesNotification_PointsFromAddress_OK
                                                            object:self
                                                          userInfo:userInfo];
        
    }
    @finally
    {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kSTXFindAddress_AddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kSTXFindAddress_AssociatedExtentKey , nil, OBJC_ASSOCIATION_ASSIGN);
    }

}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    @try {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kSTXFindAddress_AssociatedAddressKey);
        AGSEnvelope *env = objc_getAssociatedObject(op, kSTXFindAddress_AssociatedExtentKey);

        // Log to the console.
        NSLog(@"Failed to get locations for Address \"%@\" (within extent %@)", address, env);
        NSLog(@"Error: %@", error);
        
        // Build the UserInfo package that goes on the NSNotification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  op, kSTXGeoServicesNotification_WorkerOperationKey,
                                  error, kSTXGeoServicesNotification_ErrorKey,
                                  address, kSTXGeoServicesNotification_PointsFromAddress_AddressKey,
                                  env, kSTXGeoServicesNotification_PointsFromAddress_ExtentKey,
								  nil];

        // And alert our listeners that there was an error.
        [[NSNotificationCenter defaultCenter] postNotificationName:kSTXGeoServicesNotification_PointsFromAddress_Error
                                                            object:self
                                                          userInfo:userInfo];
    }
    @finally {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kSTXFindAddress_AddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kSTXFindAddress_AssociatedExtentKey , nil, OBJC_ASSOCIATION_ASSIGN);
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
														 forKey:kSTXGeoServicesNotification_FindRoute_RouteTaskResultsKey];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSTXGeoServicesNotification_FindRoute_OK
														object:self
													  userInfo:userInfo];
}

- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error
{
    NSLog(@"Failed to get route: %@", error);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSTXGeoServicesNotification_FindRoute_Error
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
    
    firstStop.name = kSTXRoutingStartPointName;
    lastStop.name = kSTXRoutingEndPointName;
    
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
@end
