//
//  AGSMapView+Geocoding.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Geocoding)
- (NSOperation *) findAddress:(NSString *)singleLineAddress;
- (NSOperation *) findAddress:(NSString *)singleLineAddress withDelegate:(id<AGSLocatorDelegate>)delegate;

- (NSOperation *) getAddressForLat:(double)latitude Lon:(double)longitude;
- (NSOperation *) getAddressForLat:(double)latitude Lon:(double)longitude withDelegate:(id<AGSLocatorDelegate>)delegate;

- (NSOperation *) getAddressForMapPoint:(AGSPoint *)mapPoint;
- (NSOperation *) getAddressForMapPoint:(AGSPoint *)mapPoint withDelegate:(id<AGSLocatorDelegate>)delegate;
@end
