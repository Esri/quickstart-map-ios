//
//  AGSMapView+GeoServices.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/10/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "AGSStarterGeoServices.h"

@interface AGSMapView (GeoServices)
- (AGSStarterGeoServices *) geoServices;
@end
