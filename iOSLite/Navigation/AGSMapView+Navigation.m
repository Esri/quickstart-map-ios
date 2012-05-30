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
// PUBLIC
- (void) centerAtLat:(double) latitude Lng:(double) longitude withScaleLevel:(int)scaleLevel
{
    AGSPoint *webMercatorCenterPt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
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

- (void) centerAtLat:(double) latitude Lng:(double) longitude
{
    AGSPoint *p = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    [self centerAtPoint:p animated:YES];
}

CLLocationManager * __ednLiteLocationManager = nil;

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[__ednLiteLocationManager stopUpdatingHeading];
	NSLog(@"Located me at %.4f,%.4f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);	
	[self centerAtLat:newLocation.coordinate.latitude
				  Lng:newLocation.coordinate.longitude];
	__ednLiteLocationManager = nil;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[__ednLiteLocationManager stopUpdatingHeading];
	__ednLiteLocationManager = nil;
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
@end