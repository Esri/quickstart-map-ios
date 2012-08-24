//
//  AGSMapView+LiteNavigation.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Navigation.h"
#import "EQSGeoServices.h"

#import "AGSPoint+GeneralUtilities.h"

#import "EQSHelper.h"
#import <CoreLocation/CoreLocation.h>

@implementation AGSMapView (Navigation)
NSInteger __eqsScaleForGeolocation = -1;

#pragma mark - Center
- (void) centerAtLat:(double) latitude Lon:(double) longitude withScaleLevel:(NSInteger)scaleLevel
{
    // Build an AGSPoint using the Lat and Long
    AGSPoint *webMercatorCenterPt = [AGSPoint pointFromLat:latitude Lon:longitude];
    
    [self centerAtPoint:webMercatorCenterPt withScaleLevel:scaleLevel];
}

- (void) centerAtLat:(double) latitude Lon:(double) longitude
{
    AGSPoint *p = [AGSPoint pointFromLat:latitude Lon:longitude];
    
    // Here's the code to do the zoom, but we don't know whether we want to run it now, or
    // need to queue it up until the AGSMapView is loaded.
    
    [self doActionWhenLoaded:^void {
        [self centerAtPoint:p animated:YES];
    }];

}

- (void) centerAtPoint:(AGSPoint *)point withScaleLevel:(NSInteger)scaleLevel
{
    // Get the map scale represented by the integer level
    double scaleForLevel = [EQSHelper getScaleForLevel:scaleLevel];
    
    [self doActionWhenLoaded:^void {
        AGSPoint *zoomPoint = [point getWebMercatorAuxSpherePoint];
        [self zoomToScale:scaleForLevel withCenterPoint:zoomPoint animated:YES];
    }];
}

#pragma mark - Zoom
- (void) zoomToLevel:(NSInteger)level
{
    AGSPoint *currentCenterPoint = self.visibleArea.envelope.center;
    double scaleForLevel = [EQSHelper getScaleForLevel:level];
    [self doActionWhenLoaded:^void {
        [self zoomToScale:scaleForLevel withCenterPoint:currentCenterPoint animated:YES];
    }];
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
    return [self.visibleArea.envelope.center getWGS84Point];
}

#pragma mark - Handle geolocation notifications
- (void) centerAtMyLocationWithScaleLevel:(NSInteger)scaleLevel
{
    __eqsScaleForGeolocation = scaleLevel;
    [self centerAtMyLocation];
}

- (void) gotLocation:(NSNotification *)notification
{
    CLLocation *newLocation = [notification geolocationResult];
    [self doActionWhenLoaded:^void {
        if (__eqsScaleForGeolocation == -1)
        {
            [self centerAtLat:newLocation.coordinate.latitude
                          Lon:newLocation.coordinate.longitude];
        }
        else
        {
            [self centerAtLat:newLocation.coordinate.latitude
                          Lon:newLocation.coordinate.longitude
               withScaleLevel:__eqsScaleForGeolocation];
        }
        __eqsScaleForGeolocation = -1;
    }];
}

- (void) failedToGetLocation:(NSNotification *)notification
{
    NSLog(@"Error getting location: %@", [notification geoServicesError]);
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