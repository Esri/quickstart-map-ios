//
//  AGSMapView+Geocoding.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Geocoding)
- (void) findAddress:(NSString *)singleLineAddress;
- (void) getAddressForLat:(double)latitude Lon:(double)longitude;
- (void) getAddressForMapPoint:(AGSPoint *)mapPoint;
@end
