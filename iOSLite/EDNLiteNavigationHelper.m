//
//  EDNLiteNavigationHelper.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/18/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNLiteNavigationHelper.h"
#import <CoreLocation/CoreLocation.h>

@interface EDNLiteNavigationHelper () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation EDNLiteNavigationHelper

@synthesize locationManager = _locationManager;

- (void) getLocation
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

- (BOOL) isEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
	NSLog(@"Located me at %.4f,%.4f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeolocationSucceeded
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:@"newLocation"]];
	self.locationManager = nil;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeolocationError
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:@"error"]];
	NSLog(@"Error getting location: %@", error);
    self.locationManager = nil;
}

@end
