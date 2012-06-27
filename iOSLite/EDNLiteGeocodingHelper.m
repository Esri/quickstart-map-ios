//
//  EDNLiteGeocodingHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNLiteGeocodingHelper.h"
#import "AGSMapView+GeneralUtilities.h"
#import "AGSMutableEnvelope+GeneralUtilities.h"
#import "EDNLiteHelper.h"
#import "/usr/include/objc/runtime.h"

#define kEDNLiteNALocatorURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"
// #define kEDNLiteNALocatorURL @"http://tasks.arcgis.com/ArcGIS/rest/services/WorldLocator/GeocodeServer"
#define kEDNLiteGeocodingResultsLayerName @"EDNLiteGeocodeResults"
#define kEDNLiteAssociatedAddressKey "address"
#define kEDNLiteAssociatedLocationKey "location"
#define kEDNLiteAssociatedDistanceKey "searchDistance"

@interface EDNLiteGeocodingHelper ()<AGSLocatorDelegate>
@property (nonatomic, retain, readwrite) AGSGraphicsLayer *resultsGraphicsLayer;
@property (nonatomic, retain, readwrite) AGSLocator *locator;
@end

@implementation EDNLiteGeocodingHelper
@synthesize resultsGraphicsLayer = _resultsGraphicsLayer;
@synthesize locator = _locator;
@synthesize delegate = _delegate;

- (id) initWithNALocator
{
    if ([self init])
    {
        self.resultsGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kEDNLiteNALocatorURL]];
        self.locator.delegate = self;
    }
    
    return self;
}

- (void) dealloc
{
    self.resultsGraphicsLayer = nil;
    self.locator = nil;
    self.delegate = nil;
}

+ (EDNLiteGeocodingHelper *) ednLiteGeocodingHelper
{
    return [[EDNLiteGeocodingHelper alloc] initWithNALocator];
}

+ (EDNLiteGeocodingHelper *) ednLiteGeocodingHelperForMapView:(AGSMapView *)mapView
{
    EDNLiteGeocodingHelper *result = [EDNLiteGeocodingHelper ednLiteGeocodingHelper];
    [result ensureResultsLayerPresentOnMapView:mapView];
    return result;
}

- (void) ensureResultsLayerPresentOnMapView:(AGSMapView *)mapView
{
    BOOL shouldAddLayer = NO;

    AGSLayer *existingLayer = [mapView getLayerForName:kEDNLiteGeocodingResultsLayerName];
    if (existingLayer)
    {
        // Found a layer. If it's not ours, remove it to make way for ours
        if (existingLayer != self.resultsGraphicsLayer)
        {
            // Some other helper is on there. Let's remove that for now.
            [mapView removeMapLayerWithName:kEDNLiteGeocodingResultsLayerName];
            shouldAddLayer = YES;
        }
    }
    else
    {
        // No layer found. Need to add ours.
        shouldAddLayer = YES;
    }
    
    if (shouldAddLayer)
    {
        // Add our layer
        [mapView addMapLayer:self.resultsGraphicsLayer withName:kEDNLiteGeocodingResultsLayerName];
    }
}

- (NSOperation *) findAddress:(NSString *)address
{
    // Tell the service we are providing a single line address.
    NSDictionary *params = [NSDictionary dictionaryWithObject:address forKey:@"SingleLine"];
    // List the fields we want back.
    NSArray *outFields = [NSArray arrayWithObjects:@"Loc_name", @"Shape", nil];
    
    // Set off the request, and get a handle on the processing operation.
    NSOperation *op = [self.locator locationsForAddress:params returnFields:outFields];
    
    // Associate the requested address with the operation - we'll read this later.
    objc_setAssociatedObject(op, kEDNLiteAssociatedAddressKey, address, OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (NSOperation *) getAddressForLocation:(AGSPoint *)location WithSearchDistance:(double)searchDistance
{
    NSOperation *op = [self.locator addressForLocation:location maxSearchDistance:searchDistance];
    
    // Associate the request params with the operation - we'll read these later.
    objc_setAssociatedObject(op, kEDNLiteAssociatedLocationKey, location, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(op, kEDNLiteAssociatedDistanceKey, [NSNumber numberWithDouble:searchDistance], OBJC_ASSOCIATION_RETAIN);
    
    return op;
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindAddressForLocation:(AGSAddressCandidate *)candidate
{
    @try {
        AGSPoint *location = objc_getAssociatedObject(op, kEDNLiteAssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEDNLiteAssociatedDistanceKey);
        NSLog(@"Found address at %@ within %@ units of %@: %@", candidate.location, distance, 
              [EDNLiteHelper getWGS84PointFromPoint:location], candidate.address);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  candidate, @"candidate",
                                  location, @"mapPoint", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_AddressForPointOK
                                                            object:self
                                                          userInfo:userInfo];

        // Also pass on the delegate call in the old style, in case anyone wants it.
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(locator:operation:didFindAddressForLocation:)])
        {
            [self.delegate locator:locator operation:op didFindAddressForLocation:candidate];
        }
    }
    @finally {
        objc_setAssociatedObject(op, kEDNLiteAssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteAssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }    
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailAddressForLocation:(NSError *)error
{
    @try {
        AGSPoint *location = objc_getAssociatedObject(op, kEDNLiteAssociatedLocationKey);
        NSNumber *distance = objc_getAssociatedObject(op, kEDNLiteAssociatedDistanceKey);
        NSLog(@"Failed to get address within %@ units of %@", distance, location);
    }
    @finally {
        objc_setAssociatedObject(op, kEDNLiteAssociatedLocationKey, nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(op, kEDNLiteAssociatedDistanceKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }    
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    @try
    {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kEDNLiteAssociatedAddressKey);
        
        // Build a dictionary of useful info which listeners to our notification might want.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  candidates, kEDNLiteGeocodingResultAddressCandidates,
                                  address, kEDNLiteGeocodingResultAddressQuery,
                                  nil];
        // Post the notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_AddressSearchOK
                                                            object:self
                                                          userInfo:userInfo];
        
        // Also pass on the delegate call in the old style, in case anyone wants it.
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(locator:operation:didFindLocationsForAddress:)])
        {
            [self.delegate locator:locator operation:op didFindLocationsForAddress:candidates];
        }
    }
    @finally
    {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kEDNLiteAssociatedAddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    @try 
    {
        // Get the address that we associated with the NSOperation when we made the request.
        NSString *address = objc_getAssociatedObject(op, kEDNLiteAssociatedAddressKey);

        // Build a dictionary of useful info which listeners to our notification might want.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  error, kEDNLiteGeocodingResultError,
                                  address, kEDNLiteGeocodingResultAddressQuery,
                                  nil];
        // Post the notification.
        [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeocodingNotification_AddressSearchError
                                                            object:self
                                                          userInfo:userInfo];

        // Also pass on the delegate call in the old style, in case anyone wants it.
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(locator:operation:didFindLocationsForAddress:)])
        {
            [self.delegate locator:locator operation:op didFailLocationsForAddress:error];
        }
    }
    @finally {
        // Remove the associated address. This would probably happen automatically when the
        // operation is released, but it's good to be responsile.
        objc_setAssociatedObject(op, kEDNLiteAssociatedAddressKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}
@end