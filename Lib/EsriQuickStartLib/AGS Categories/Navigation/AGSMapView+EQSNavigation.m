//
//  AGSMapView+LiteNavigation.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+EQSGeneralUtilities.h"
#import "AGSMapView+EQSNavigation.h"
#import "EQSGeoServices.h"

#import "AGSMapView+EQSGraphics.h"

#import "AGSPoint+EQSGeneralUtilities.h"

#import "EQSHelper_int.h"
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

@implementation AGSMapView (EQSNavigation)
#define kEQSNavigationGeolocationTargetScaleKey @"EQSGeolocationTargetScale"
#define kEQSNavigationZoomToPlaceShouldAnimateKey @"EQSNavigationZoomAnimate"

#pragma mark - Center
- (void) centerAtLat:(double) latitude lon:(double) longitude animated:(BOOL)animated
{
    AGSPoint *p = [AGSPoint pointFromLat:latitude lon:longitude];
    
    // Here's the code to do the zoom, but we don't know whether we want to run it now, or
    // need to queue it up until the AGSMapView is loaded.
    
    [self doActionWhenLoaded:^void {
        [self centerAtPoint:p animated:animated];
    }
                    withName:@"Center at Lat Lon"];
}

#pragma mark - Zoom
- (void) zoomToLevel:(NSUInteger)level animated:(BOOL)animated
{
    AGSPoint *currentCenterPoint = self.visibleArea.envelope.center;
    [self zoomToLevel:level withCenterPoint:currentCenterPoint animated:animated];
}

- (void) zoomToLevel:(NSUInteger)level withCenterPoint:(AGSPoint *)centerPoint animated:(BOOL)animated
{
    // Get the map scale represented by the integer level
    double scaleForLevel = [EQSHelper getScaleForLevel:level];
    
    [self doActionWhenLoaded:^void {
        AGSPoint *zoomPoint = [centerPoint getWebMercatorAuxSpherePoint];
        [self zoomToScale:scaleForLevel withCenterPoint:zoomPoint animated:animated];
    }
                    withName:@"Zoom To Level With Centerpoint"];
}

- (void) zoomToLevel:(NSUInteger)level withLat:(double)latitude lon:(double)longitude animated:(BOOL)animated
{
    // Build an AGSPoint using the Lat and Long
    AGSPoint *p = [AGSPoint pointFromLat:latitude lon:longitude];
    
    [self zoomToLevel:level withCenterPoint:p animated:animated];
}

- (void) zoomToPlace:(NSString *)searchString animated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotZoomResult:)
                                                 name:kEQSGeoServicesNotification_PointsFromAddress_OK
                                               object:self.geoServices];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errorGettingZoomResult:)
                                                 name:kEQSGeoServicesNotification_PointsFromAddress_Error
                                               object:self.geoServices];
    
    NSOperation *findOp = [self.geoServices findPlaces:searchString];
    objc_setAssociatedObject(findOp, kEQSNavigationZoomToPlaceShouldAnimateKey, [NSNumber numberWithBool:animated], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) gotZoomResult:(NSNotification *)notification
{
    NSNumber *n = objc_getAssociatedObject(notification.geoServicesOperation, kEQSNavigationZoomToPlaceShouldAnimateKey);
    BOOL b = n.boolValue;
    if (b)
    {
        NSArray *foundPlaces = notification.findPlacesCandidatesSortedByScore;
        
        if (foundPlaces.count > 0)
        {
            for (AGSAddressCandidate *candidate in foundPlaces)
            {
                AGSEnvelope *extent = candidate.placeExtent;
                if (extent)
                {
                    NSNumber *boolNum = objc_getAssociatedObject(notification.geoServicesOperation, kEQSNavigationZoomToPlaceShouldAnimateKey);
                    BOOL animated = boolNum.boolValue;
                    [EQSHelper queueBlock:^{
                        [self zoomToEnvelope:extent animated:animated];
                        [self removeGraphicsByAttribute:@"ZoomGraphic" withValue:@"YES"];
                    } untilMapViewLoaded:self withBlockName:@"zoomToPlace"];
                    return;
                }
            }
            NSLog(@"No address candidates had extents defined to zoom the map to: %@", notification.findPlacesSearchString);
            return;
        }
        
        NSLog(@"No address candidates to zoom the map to: %@", notification.findPlacesSearchString);
    }
}

- (void) errorGettingZoomResult:(NSNotification *)notification
{
    if (notification.findPlacesWasZoomToPlaceRequest)
    {
        NSError *error = notification.geoServicesError;
        NSLog(@"Error finding candidates to zoom the map to (%@): %@", notification.findPlacesSearchString, error.localizedDescription);
    }
}


#pragma mark - Geolocation (GPS)
- (void) centerAtMyLocation
{
    [self ensureNavigationHelperInitialized];
    
    if ([self.geoServices isGeolocationEnabled])
    {
        [self.geoServices findMyLocation];
    }
	else {
		UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"Cannot Find You" message:@"Location Services Not Enabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[v show];
	}
}

#pragma mark - Centerpoint of map
- (AGSPoint *) getCenterPoint
{
    return [self.visibleArea.envelope.center getWebMercatorAuxSpherePoint];
}

- (NSUInteger) getZoomLevel
{
    return [EQSHelper getLevelForScale:self.mapScale];
}

#pragma mark - Handle geolocation notifications
- (void) centerAtMyLocationWithZoomLevel:(NSUInteger)level
{
	objc_setAssociatedObject(self, kEQSNavigationGeolocationTargetScaleKey, [NSNumber numberWithUnsignedInteger:level], OBJC_ASSOCIATION_RETAIN);
    [self centerAtMyLocation];
}

- (void) gotLocation:(NSNotification *)notification
{
    CLLocation *newLocation = [notification geolocationResult];
    [self doActionWhenLoaded:^void {
		NSNumber *temp = objc_getAssociatedObject(self, kEQSNavigationGeolocationTargetScaleKey);
		NSUInteger scaleForGeolocation = -1;
		if (temp)
		{
			scaleForGeolocation = temp.unsignedIntegerValue;
			objc_setAssociatedObject(self, kEQSNavigationGeolocationTargetScaleKey, nil, OBJC_ASSOCIATION_ASSIGN);
		}
		
        if (scaleForGeolocation == -1)
        {
            [self centerAtLat:newLocation.coordinate.latitude
                          lon:newLocation.coordinate.longitude
                     animated:YES];
        }
        else
        {
            [self zoomToLevel:scaleForGeolocation
                      withLat:newLocation.coordinate.latitude
                          lon:newLocation.coordinate.longitude
                     animated:YES];
        }
    }
                    withName:@"Zoom/Center to my location"];
}

- (void) failedToGetLocation:(NSNotification *)notification
{
    NSLog(@"Error getting location: %@", [notification geoServicesError]);
	objc_setAssociatedObject(self, kEQSNavigationGeolocationTargetScaleKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

- (void) ensureNavigationHelperInitialized
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(gotLocation:)
												 name:kEQSGeoServicesNotification_Geolocation_OK
											   object:self.geoServices];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(failedToGetLocation:)
												 name:kEQSGeoServicesNotification_Geolocation_Error
											   object:self.geoServices];
}
@end

@implementation NSNotification (EQSNavigation)
- (BOOL) findPlacesWasZoomToPlaceRequest
{
    NSNumber *n = objc_getAssociatedObject(self, kEQSNavigationZoomToPlaceShouldAnimateKey);
    return n != nil;
}
@end

