//
//  AGSMapView+Routing.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSRouteDisplayHelper.h"

@interface AGSMapView (EQSDirections)
- (EQSRouteDisplayHelper *)routeDisplayHelper;
@end
