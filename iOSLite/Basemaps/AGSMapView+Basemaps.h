//
//  AGSMapView+Basemaps.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSBasemapTypeEnum.h"

#define kEQSNotification_BasemapDidChange @"BasemapDidChange"

@interface AGSMapView (Basemaps)
- (void) setBasemap:(EQSBasemapType)basemapType;
@end
