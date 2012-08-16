//
//  AGSMapView+Basemaps.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "STXBasemapTypeEnum.h"

#define kSTXNotification_BasemapDidChange @"BasemapDidChange"

@interface AGSMapView (Basemaps)
- (void) setBasemap:(STXBasemapType)basemapType;
@end
