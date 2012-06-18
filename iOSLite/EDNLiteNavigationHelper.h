//
//  EDNLiteNavigationHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/18/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEDNLiteGeolocationSucceeded @"EDNLiteGeolocationSucceeded"
#define kEDNLiteGeolocationError @"EDNLiteGeolocationError"
#define kEDNLiteGeolocationSucceededLocationKey @"newLocation"

@interface EDNLiteNavigationHelper : NSObject
- (id) init;
- (void) start;
- (void) stop;
- (BOOL) isEnabled;
@end
