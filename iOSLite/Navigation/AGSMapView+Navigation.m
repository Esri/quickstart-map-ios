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

@implementation AGSMapView (EQSNavigation)
NSInteger __eqsScaleForGeolocation = -1;

#pragma mark - Center
- (void) centerAtLat:(double) latitude lon:(double) longitude animated:(BOOL)animated
{
    AGSPoint *p = [AGSPoint pointFromLat:latitude lon:longitude];
    
    // Here's the code to do the zoom, but we don't know whether we want to run it now, or
    // need to queue it up until the AGSMapView is loaded.
    
    [self doActionWhenLoaded:^void {
        [self centerAtPoint:p animated:animated];
    }];
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
    }];
}

- (void) zoomToLevel:(NSUInteger)level withLat:(double)latitude lon:(double)longitude animated:(BOOL)animated
{
    // Build an AGSPoint using the Lat and Long
    AGSPoint *p = [AGSPoint pointFromLat:latitude lon:longitude];
    
    [self zoomToLevel:level withCenterPoint:p animated:animated];
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
    __eqsScaleForGeolocation = level;
    [self centerAtMyLocation];
}

- (void) gotLocation:(NSNotification *)notification
{
    CLLocation *newLocation = [notification geolocationResult];
    [self doActionWhenLoaded:^void {
        if (__eqsScaleForGeolocation == -1)
        {
            [self centerAtLat:newLocation.coordinate.latitude
                          lon:newLocation.coordinate.longitude
                     animated:YES];
        }
        else
        {
            [self zoomToLevel:__eqsScaleForGeolocation
                      withLat:newLocation.coordinate.latitude
                          lon:newLocation.coordinate.longitude
                     animated:YES];
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