//
//  EQSBasemapsNotifications.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#ifndef esriQuickStartApp_EQSBasemapsNotifications_h
#define esriQuickStartApp_EQSBasemapsNotifications_h

#import <ArcGIS/ArcGIS.h>
#import "EQSBasemapTypeEnum.h"

#define kEQSNotification_BasemapDidChange @"EQSBasemapDidChange"

// Convenience accessors to read info from the basemap notifications
@interface NSNotification (EQSBasemaps)
@property (nonatomic, readonly) AGSPortalItem *basemapPortalItem;
@property (nonatomic, readonly) EQSBasemapType basemapType;
@end

#endif
