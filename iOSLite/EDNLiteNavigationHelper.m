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
@property (nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation EDNLiteNavigationHelper

@synthesize locationManager = _locationManager;

- (id) init
{
    self = [super init];
    if (self)
    {
        // Do additional init in here.
    }
    return self;
}

- (void) start
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingHeading];
}

- (void) stop
{
    [self.locationManager stopUpdatingHeading];
    self.locationManager = nil;
}

- (BOOL) isEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self stop];
	NSLog(@"Located me at %.4f,%.4f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeolocationSucceeded
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:@"newLocation"]];
	
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEDNLiteGeolocationError
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:error
                                                                                           forKey:@"error"]];
	NSLog(@"Error getting location: %@", error);
}

@end
