//
//  AGSMapView+Geocoding.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Geocoding.h"
#import	"AGSMapView+GeneralUtilities.h"
#import "EDNLiteHelper.h"

@interface AGSMapView ()<AGSLocatorDelegate>
@end

@implementation AGSMapView (Geocoding)
#define kEDNLiteGeocoderServiceURL @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer"
#define kEDNLiteGeocodeResultsGraphicsLayerName @"EDNLiteGeocodeResults"

AGSLocator * __ednLiteLocator;
AGSGraphicsLayer *__ednLiteLocatorResultsLayer;

- (void) findAddress:(NSString *)singleLineAddress
{
    [self __ednLiteLocatorInit];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:singleLineAddress forKey:@"SingleLine"];
    NSArray *outFields = [NSArray arrayWithObjects:@"Loc_name", @"Shape", nil];
    
    [__ednLiteLocator locationsForAddress:params returnFields:outFields];
}

- (void) getAddressForLat:(double)latitude Lon:(double)longitude
{
    [self getAddressForMapPoint:[EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Lon:longitude]];
}

- (void) getAddressForMapPoint:(AGSPoint *)mapPoint
{
	
}

- (void) __ednLiteLocatorInit
{
    if (!__ednLiteLocator)
    {
        __ednLiteLocator = [AGSLocator locatorWithURL:[NSURL URLWithString:kEDNLiteGeocoderServiceURL]];
        __ednLiteLocator.delegate = self;
    }

	if (![self getLayerForName:kEDNLiteGeocodeResultsGraphicsLayerName])
	{
		// We need to add the graphics layer
		if (!__ednLiteLocatorResultsLayer)
		{
			__ednLiteLocatorResultsLayer = [AGSGraphicsLayer graphicsLayer];
		}
		[self addMapLayer:__ednLiteLocatorResultsLayer withName:kEDNLiteGeocodeResultsGraphicsLayerName];
	}
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
	BOOL gotFirst = NO;
	NSUInteger scoreThreshold = 80;
	// First, sort the array
	NSArray *sortedResults = [candidates sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
		{
			AGSAddressCandidate *can1 = (AGSAddressCandidate *)obj1;
			AGSAddressCandidate *can2 = (AGSAddressCandidate *)obj2;
			// We want higher scores to come first...
			return (can1.score == can2.score)?NSOrderedSame:(can1.score > can2.score)?NSOrderedAscending:NSOrderedDescending;
		}];

	for (AGSAddressCandidate *candidate in sortedResults) {
		NSLog(@"Got address candidate (score %f, location %@): %@", candidate.score, candidate.location, candidate.addressString);
		if (!gotFirst &&
			candidate.score > scoreThreshold)
		{
			gotFirst = YES;
			AGSSimpleMarkerSymbol *sym = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
			sym.style = AGSSimpleMarkerSymbolStyleDiamond;
			AGSPoint *loc = [EDNLiteHelper getWebMercatorAuxSpherePointFromWGS84Point:candidate.location];
			NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:@"LocatorResult" forKey:@"PointType"];
			AGSGraphic *resultGraphic = [AGSGraphic graphicWithGeometry:loc symbol:sym attributes:attributes infoTemplateDelegate:nil];
			[__ednLiteLocatorResultsLayer removeAllGraphics];
			[__ednLiteLocatorResultsLayer addGraphic:resultGraphic];
			[__ednLiteLocatorResultsLayer dataChanged];
		}
	}
}

- (void) locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    NSLog(@"Failed to get location for address: %@", error);
}
@end
