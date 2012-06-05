//
//  AGSMapView+LiteNavigation.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Navigation.h"
#import "EDNLiteHelper.h"
#import <CoreLocation/CoreLocation.h>

@interface AGSMapView ()<CLLocationManagerDelegate>

@end

@implementation AGSMapView (Navigation)
CLLocationManager * __ednLiteLocationManager = nil;
NSInteger __ednLiteScaleForGeolocation = -1;

// PUBLIC
- (void) centerAtLat:(CGFloat) latitude Lng:(CGFloat) longitude withScaleLevel:(NSInteger)scaleLevel
{
    AGSPoint *webMercatorCenterPt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Lon:longitude];
    double scale = [EDNLiteHelper getScaleForLevel:scaleLevel];
    if (self.loaded)
    {
        NSLog(@"Loaded");
        [self zoomToScale:scale withCenterPoint:webMercatorCenterPt animated:YES];
    }
    else 
    {
        NSLog(@"Not Loaded: %d", self.loaded);
        [EDNLiteHelper queueBlock:^{
            [self zoomToScale:scale withCenterPoint:webMercatorCenterPt animated:YES];
        } untilMapViewLoaded:self];
    }
}

- (void) centerAtLat:(CGFloat) latitude Lng:(CGFloat) longitude
{
    AGSPoint *p = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Lon:longitude];
    [self centerAtPoint:p animated:YES];
}

- (void) zoomToLevel:(NSInteger)level
{
    AGSPoint *currentCenterPoint = self.visibleArea.envelope.center;
    double scaleForLevel = [EDNLiteHelper getScaleForLevel:level];
    [self zoomToScale:scaleForLevel withCenterPoint:currentCenterPoint animated:YES];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[__ednLiteLocationManager stopUpdatingHeading];
	NSLog(@"Located me at %.4f,%.4f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	
    if (__ednLiteScaleForGeolocation == -1)
    {
	[self centerAtLat:newLocation.coordinate.latitude
				  Lng:newLocation.coordinate.longitude];
    }
    else
    {
        [self centerAtLat:newLocation.coordinate.latitude
                      Lng:newLocation.coordinate.longitude
           withScaleLevel:__ednLiteScaleForGeolocation];
    }
	__ednLiteLocationManager = nil;
    __ednLiteScaleForGeolocation = -1;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[__ednLiteLocationManager stopUpdatingHeading];
	__ednLiteLocationManager = nil;
    __ednLiteScaleForGeolocation = -1;
	NSLog(@"Error getting location: %@", error);
}

- (void) centerAtMyLocation
{
	if ([CLLocationManager locationServicesEnabled])
	{
		if (!__ednLiteLocationManager)
		{
			__ednLiteLocationManager = [[CLLocationManager alloc] init];
			__ednLiteLocationManager.delegate = self;
			__ednLiteLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
			__ednLiteLocationManager.distanceFilter = 20;
			[__ednLiteLocationManager startUpdatingLocation];
		}
	}
	else {
		UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"Cannot Find You" message:@"Location Services Not Enabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[v show];
	}
}

- (void) centerAtMyLocationWithScaleLevel:(NSInteger)scaleLevel
{
    __ednLiteScaleForGeolocation = scaleLevel;
    [self centerAtMyLocation];
}

- (AGSPoint *) getCenterPointWebMercator
{
    return self.visibleArea.envelope.center;    
}

- (AGSPoint *) getCenterPoint
{
    return [EDNLiteHelper getWGS84PointFromWebMercatorAuxSpherePoint:[self getCenterPointWebMercator]];
}
@end