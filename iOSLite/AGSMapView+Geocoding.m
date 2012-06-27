//
//  AGSMapView+Geocoding.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Geocoding.h"
#import	"AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Navigation.h"
#import "EDNLiteGeocodingHelper.h"
#import "EDNLiteHelper.h"

@implementation AGSMapView (Geocoding)
EDNLiteGeocodingHelper *__ednLiteGeocodingHelper = nil;

#pragma mark - Simple functions that just update the map
- (NSOperation *) findAddress:(NSString *)singleLineAddress
{
    return [self findAddress:singleLineAddress withDelegate:nil];
}

- (NSOperation *) getAddressForLat:(double)latitude 
							   Lon:(double)longitude
{
    return [self getAddressForLat:latitude Lon:longitude withDelegate:nil];
}

- (NSOperation *) getAddressForMapPoint:(AGSPoint *)mapPoint
{
    return [self getAddressForMapPoint:mapPoint withDelegate:nil];
}


#pragma mark - Delegate Functions that allow the caller to take further action.
- (NSOperation *) findAddress:(NSString *)singleLineAddress 
				 withDelegate:(id<AGSLocatorDelegate>)delegate
{
    [self __ednLiteLocatorLazyInit];
    __ednLiteGeocodingHelper.delegate = delegate;
    return [__ednLiteGeocodingHelper findAddress:singleLineAddress];
}

- (NSOperation *) getAddressForLat:(double)latitude 
							   Lon:(double)longitude 
					  withDelegate:(id<AGSLocatorDelegate>)delegate
{
    return [self getAddressForMapPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude]
						  withDelegate:delegate];
}

- (NSOperation *) getAddressForMapPoint:(AGSPoint *)mapPoint 
						   withDelegate:(id<AGSLocatorDelegate>)delegate
{
    [self __ednLiteLocatorLazyInit];
    __ednLiteGeocodingHelper.delegate = delegate;
    return [__ednLiteGeocodingHelper getAddressForLocation:mapPoint WithSearchDistance:100];
}


#pragma mark - Initialization

- (void) __ednLiteLocatorLazyInit
{
    if (!__ednLiteGeocodingHelper)
    {
        // Initialize.
        __ednLiteGeocodingHelper = [EDNLiteGeocodingHelper ednLiteGeocodingHelperForMapView:self];
        
        // Register our interest in knowing when a geocode succeeded or failed.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(__ednLiteFoundAddressLocations:)
                                                     name:kEDNLiteGeocodingNotification_AddressSearchOK
                                                   object:__ednLiteGeocodingHelper];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(__ednLiteErrorFindingAddressLocations:)
                                                     name:kEDNLiteGeocodingNotification_AddressSearchError
                                                   object:__ednLiteGeocodingHelper];
    }
}

#pragma mark - Geocoding Handler Functions

- (void) __ednLiteFoundAddressLocations:(NSNotification *)notification
{
    NSLog(@"Search done");
    // Extract the information we need.
    NSArray *candidates = [notification.userInfo objectForKey:kEDNLiteGeocodingResultAddressCandidates];
    NSString *address = [notification.userInfo objectForKey:kEDNLiteGeocodingResultAddressQuery];
    
    // Handle the case when we succeeded the geocode, but no suitable results came back.
    if (candidates.count == 0)
    {
        NSLog(@"No results for %@", address);
        return;
    }

	// First, sort the array so higher scores come first.
	NSArray *sortedResults = [candidates sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
		{
			AGSAddressCandidate *can1 = (AGSAddressCandidate *)obj1;
			AGSAddressCandidate *can2 = (AGSAddressCandidate *)obj2;
			// We want higher scores to come first...
			return (can1.score == can2.score)?NSOrderedSame:(can1.score > can2.score)?NSOrderedAscending:NSOrderedDescending;
		}];

    // Now use the score of the first item to get the highest score of all results.
    double topScore = ((AGSAddressCandidate *)[sortedResults objectAtIndex:0]).score;
    
    // Use a threshold as a workaround for the 10.0 services. Have found results that should be
    // 100% matches but that aren't...
    double threshold = topScore * 0.98; // Get candidates within 2% of the top score, just to be safe.
    
    NSLog(@"Top Score = %f, Threshold = %f", topScore, threshold);

    // Clear the graphics layer.
    [__ednLiteGeocodingHelper.resultsGraphicsLayer removeAllGraphics];

    // Create a symbol to display results on the map with
    AGSSimpleMarkerSymbol *sym = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
    sym.style = AGSSimpleMarkerSymbolStyleDiamond;

    // Keep track of the extent of all the suitable results. We'll zoom to this extent.
    AGSMutableEnvelope *totalEnvelope = nil;
	for (AGSAddressCandidate *candidate in sortedResults) {
		NSLog(@"Got address candidate (score %f, location %@): %@", 
              candidate.score, candidate.location, candidate.addressString);
		if (candidate.score >= threshold)
		{
            // Get the result location.
			AGSPoint *loc = [EDNLiteHelper getWebMercatorAuxSpherePointFromPoint:candidate.location];
            
            // Merge or create the extent we're going to zoom to eventually.
            if (!totalEnvelope)
            {
                // This is the first cnadidate. Create a new envelope.
				totalEnvelope = [loc.envelope mutableCopy];
            }
            else 
            {
                // Subsequent candidates must merge the envelope to track the
                // an area of the map that will cover them all.
                [totalEnvelope unionWithPoint:loc];
            }
            
            // Store some attributes on the graphic so that we can display some info.
			NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"LocatorResult", @"PointType",
                                               [NSNumber numberWithDouble:candidate.score], @"score",
                                               candidate.addressString, @"address",
                                               nil];
            
            // Create the graphic for this result.
			AGSGraphic *resultGraphic = [AGSGraphic graphicWithGeometry:loc 
                                                                 symbol:sym
                                                             attributes:attributes
                                                   infoTemplateDelegate:nil];
            
            // And add it to the map.
			[__ednLiteGeocodingHelper.resultsGraphicsLayer addGraphic:resultGraphic];
		}
	}
    
    // We cleared it before, so even if there were no results, let's flag for a redraw.
    [__ednLiteGeocodingHelper.resultsGraphicsLayer dataChanged];

    // If there were results, let's zoom to them.
    if (totalEnvelope)
    {

        if (totalEnvelope.width == 0 &&
            totalEnvelope.height == 0)
        {
            // We got a single point back.
            [self centerAtPoint:totalEnvelope.center withScaleLevel:17];
        }
        else
        {
            // We have many points. Let's expand the extent a bit so some of them aren't on the
            // very edge of the visible map.
            [totalEnvelope expandByFactor:1.1];
            // And we'll zoom to that envelope.
            [self zoomToEnvelope:totalEnvelope animated:YES];
        }
    }
}

- (void) __ednLiteErrorFindingAddressLocations:(NSNotification *)notification
{
    NSError *error = [notification.userInfo objectForKey:kEDNLiteGeocodingResultError];
    NSLog(@"Failed to get location for address: %@", error);
}
@end
