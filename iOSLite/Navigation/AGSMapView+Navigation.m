//
//  AGSMapView+LiteNavigation.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+GeneralUtilities.h"
#import "AGSMapView+Navigation.h"
#import "STXHelper.h"
#import <CoreLocation/CoreLocation.h>

@implementation AGSMapView (Navigation)
NSInteger __ednLiteScaleForGeolocation = -1;

#pragma mark - Center
- (void) centerAtLat:(double) latitude Long:(double) longitude withScaleLevel:(NSInteger)scaleLevel
{
    // Build an AGSPoint using the Lat and Long
    AGSPoint *webMercatorCenterPt = [STXHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
    [self centerAtPoint:webMercatorCenterPt withScaleLevel:scaleLevel];
}

- (void) centerAtLat:(double) latitude Long:(double) longitude
{
    AGSPoint *p = [STXHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    
    // Here's the code to do the zoom, but we don't know whether we want to run it now, or
    // need to queue it up until the AGSMapView is loaded.
    
    [self doActionWhenLoaded:^void {
        [self centerAtPoint:p animated:YES];
    }];

}

- (void) centerAtPoint:(AGSPoint *)point withScaleLevel:(NSInteger)scaleLevel
{
    // Get the map scale represented by the integer level
    double scaleForLevel = [STXHelper getScaleForLevel:scaleLevel];
    
    [self doActionWhenLoaded:^void {
        [self zoomToScale:scaleForLevel withCenterPoint:point animated:YES];
    }];
}

#pragma mark - Zoom
- (void) zoomToLevel:(NSInteger)level
{
    AGSPoint *currentCenterPoint = self.visibleArea.envelope.center;
    double scaleForLevel = [STXHelper getScaleForLevel:level];
    [self doActionWhenLoaded:^void {
        [self zoomToScale:scaleForLevel withCenterPoint:currentCenterPoint animated:YES];
    }];
}

#pragma mark - Geolocation (GPS)
- (void) centerAtMyLocation
{
    [self ensureNavigationHelperInitialized];
    
    if ([STXHelper isGeolocationEnabled])
    {
        [STXHelper getGeolocation];
    }
	else {
		UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"Cannot Find You" message:@"Location Services Not Enabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[v show];
	}
}

#pragma mark - Centerpoint of map
- (AGSPoint *) getCenterPoint
{
    return [STXHelper getWGS84PointFromPoint:self.visibleArea.envelope.center];
}

#pragma mark - Internal
- (void) centerAtMyLocationWithScaleLevel:(NSInteger)scaleLevel
{
    __ednLiteScaleForGeolocation = scaleLevel;
    [self centerAtMyLocation];
}

- (void) gotLocation:(NSNotification *)notification
{
    CLLocation *newLocation = [notification.userInfo objectForKey:kEDNLiteGeolocationSucceededLocationKey];
    [self doActionWhenLoaded:^void {
        if (__ednLiteScaleForGeolocation == -1)
        {
            [self centerAtLat:newLocation.coordinate.latitude
                         Long:newLocation.coordinate.longitude];
        }
        else
        {
            [self centerAtLat:newLocation.coordinate.latitude
                         Long:newLocation.coordinate.longitude
               withScaleLevel:__ednLiteScaleForGeolocation];
        }
        __ednLiteScaleForGeolocation = -1;
    }];
}

- (void) failedToGetLocation:(NSNotification *)notification
{
    NSLog(@"Error getting location: %@", [notification.userInfo objectForKey:@"error"]);
}

- (void) ensureNavigationHelperInitialized
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(gotLocation:)
												 name:kEDNLiteGeolocationSucceeded
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(failedToGetLocation:)
												 name:kEDNLiteGeolocationError
											   object:nil];
}
@end