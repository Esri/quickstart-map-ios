//
//  AGSStarterGeoServices.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 7/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSGeoServices.h"
#import "EQSHelper.h"

#import "AGSPoint+GeneralUtilities.h"

#import <objc/runtime.h>


#pragma mark - AGSMapView Category
@implementation AGSMapView (EQSGeoServices)
#define kEQSGeoServicesHelperKey @"EQSGeoServicesHelper"

- (EQSGeoServices *) geoServices
{
    EQSGeoServices *helper = objc_getAssociatedObject(self, kEQSGeoServicesHelperKey);
    if (helper == nil)
    {
        helper = [[EQSGeoServices alloc] init];
        objc_setAssociatedObject(self, kEQSGeoServicesHelperKey, helper, OBJC_ASSOCIATION_RETAIN);
    }
    return helper;
}
@end


#pragma mark - NSNotification Category
@implementation NSNotification (EQSGeoServices)
// kEQSGeoServicesNotification_PointsFromAddress_OK
// kEQSGeoServicesNotification_PointsFromAddress_Error
- (NSArray *) findPlacesCandidates
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_PointsFromAddress_LocationCandidatesKey];
}
- (NSString *) findPlacesSearchString
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_PointsFromAddress_AddressKey];
}
- (AGSEnvelope *) findPlacesSearchExtent
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_PointsFromAddress_ExtentKey];
}

// kEQSGeoServicesNotification_AddressFromPoint_OK
// kEQSGeoServicesNotification_AddressFromPoint_Error
- (AGSAddressCandidate *) findAddressCandidate
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_AddressFromPoint_AddressCandidateKey];
}
- (AGSPoint *) findAddressSearchPoint
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_AddressFromPoint_MapPointKey];
}
- (double) findAddressSearchDistance
{
    NSNumber *distanceNum = [self.userInfo objectForKey:kEQSGeoServicesNotification_AddressFromPoint_DistanceKey];
    return (double)distanceNum.doubleValue;
}

// kEQSGeoServicesNotification_FindRoute_OK
// kEQSGeoServicesNotification_FindRoute_Error
- (AGSRouteTaskResult *) routeTaskResults
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_FindRoute_RouteTaskResultsKey];
}

// kEQSGeoServicesNotification_Geolocation_OK
// kEQSGeoServicesNotification_Geolocation_Error
- (CLLocation *) geolocationResult
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_Geolocation_LocationKey];
}

- (NSOperation *) geoServicesOperation
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_WorkerOperationKey];
}

- (NSError *) geoServicesError
{
    return [self.userInfo objectForKey:kEQSGeoServicesNotification_ErrorKey];
}
@end



#pragma mark - Constant Definitions
//#define kEQSNALocatorURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"
#define kEQSNALocatorURL @"http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
#define kEQSFindAddress_AddressKey @"SingleLine"
#define kEQSFindAddress_ReturnFields @"Loc_name", @"Shape", @"Country", @"Addr_Type", @"Type", @"Match_Addr", @"DisplayX",@"DisplayY"
#define kEQSFindAddress_AssociatedAddressKey "address"
#define kEQSFindAddress_AssociatedExtentKey "extent"

#define kEQSNewStyleGeocoderURL @"http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

#define kEQSFindLocation_AssociatedLocationKey "location"
#define kEQSFindLocation_AssociatedDistanceKey "searchDistance"

#define kEQSMaxDistanceForReverseGeocode 100

#define kEQSRoutingRouteTaskUrl @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"
#define kEQSRoutingRouteTaskUrlEU @"http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_EU/NAServer/Route"



@interface EQSGeoServices () <AGSLocatorDelegate, AGSRouteTaskDelegate, CLLocationManagerDelegate>
// Properties to store the geoservices…
@property (nonatomic, strong) AGSLocator *locator;

@property (nonatomic, strong) AGSRouteTask *routeTask;
@property (nonatomic, strong) AGSRouteTaskParameters *defaultParameters;

@property (nonatomic, strong) CLLocationManager *locationManager;
@end


@implementation EQSGeoServices
@synthesize locator = _locator;

@synthesize routeTask = _routeTask;
@synthesize defaultParameters = _defaultParameters;

@synthesize locationManager = _locationManager;

#pragma mark - Initialization
- (id) init
{
	if (self = [super init])
	{
        // Set up the locator and route task.
		self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kEQSNALocatorURL]];
        self.locator.delegate = self;
		
		self.routeTask = [AGSRouteTask routeTaskWithURL:[NSURL URLWithString:kEQSRoutingRouteTaskUrl]];
		self.routeTask.delegate = self;
		
        // Try to get the default parameters for the route task.
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
    
    // Set off the request, using Web Mercator
    NSOperation *op = [self.locator locationsForAddress:params
                                           returnFields:outFields
                                    outSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    // Associate the requested address with the operation - we'll read this later.
    objc_setAssociatedObject(op, kEQSFindAddress_AssociatedAddressKey, singleLineAddress, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEQSFindAddress_AssociatedExtentKey, env, OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (NSOperation *) findAddressFromPoint:(AGSPoint *)mapPoint
{
	return [self findAddressFromPoint:mapPoint withMaxSearchDistance:kEQSMaxDistanceForReverseGeocode];
}

- (NSOperation *) findAddressFromPoint:(AGSPoint *)mapPoint withMaxSearchDistance:(double) searchDistance
{
    // Fire off the request (using Web Mercator for return results)
	NSOperation *op = [self.locator addressForLocation:mapPoint
                                     maxSearchDistance:searchDistance
                                   outSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    // Associate the request params with the operation - we'll read these later.
    objc_setAssociatedObject(op, kEQSFindLocation_AssociatedLocationKey, mapPoint, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEQSFindLocation_AssociatedDistanceKey, [NSNumber numberWithDouble:searchDistance], OBJC_ASSOCIATION_RETAIN);
	
    return op;
}

- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint to:(AGSPoint *)endPoint
{
    NSString *startName = [NSString stringWithFormat:@"Start Point (%.3f,%.3f)", startPoint.latitude, startPoint.longitude];
    NSString *endName = [NSString stringWithFormat:@"End Point (%.3f,%.3f)", endPoint.latitude, endPoint.longitude];

	return [self findDirectionsFrom:startPoint named:startName
                                 to:endPoint named:endName];
}

- (NSOperation *) findDirectionsFrom:(AGSPoint *)startPoint named:(NSString *)startPointName
                                  to:(AGSPoint *)endPoint named:(NSString *)endPointName
{
	AGSRouteTaskParameters *routeTaskParams = [self getParametersToRouteFromStart:startPoint Named:startPointName
                                                                           ToStop:endPoint Named:endPointName];
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
              location, candidate.address, candidate.attributes);
        // webMercatorAuxSpherePoint
        
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
        
        for (AGSAddressCandidate *candidate in candidates)
        {
            NSLog(@"Found candidate: %@ %@", candidate.addressString, candidate.attributes);

//            NSNumber *x = [candidate.attributes objectForKey:@"DisplayX"];
//            NSNumber *y = [candidate.attributes objectForKey:@"DisplayY"];
//            
//            if (x != nil && y != nil)
//            {
//                AGSPoint *displayPoint = [AGSPoint pointFromLat:y.doubleValue lon:x.doubleValue];
//                objc_setAssociatedObject(candidate, @"DisplayPoint", displayPoint, OBJC_ASSOCIATION_RETAIN);
//            }
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
//	NSLog(@"Got Default Route Task Parameters");
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
//	NSLog(@"Got route results");
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
- (AGSRouteTaskParameters *) getParametersToRouteFromStart:(AGSPoint *)startPoint 
                                                    ToStop:(AGSPoint *)stopPoint
{
    return [self getParametersToRouteFromStart:startPoint Named:kEQSRoutingStartPointName
                                        ToStop:stopPoint Named:kEQSRoutingEndPointName];
}
            
- (AGSRouteTaskParameters *) getParametersToRouteFromStart:(AGSPoint *)startPoint Named:(NSString *)startName
                                                    ToStop:(AGSPoint *)stopPoint Named:(NSString *)endName
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
    
    firstStop.name = startName;
    lastStop.name = endName;
    
    // Add them to the parameters.
    AGSRouteTaskParameters *params = self.defaultParameters;
	if (!params)
	{
		NSLog(@"Couldn't get default Route Task Parameters - using blank");
		params = [AGSRouteTaskParameters routeTaskParameters];
	}

    NSArray *routeStops = [NSArray arrayWithObjects:firstStop, lastStop, nil];
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
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
	NSLog(@"Error getting location: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kEQSGeoServicesNotification_Geolocation_Error
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:kEQSGeoServicesNotification_ErrorKey]];
}
@end