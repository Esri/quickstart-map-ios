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

@interface NSNotification (EQSBasemaps)
// Convenience accessors to read info from the basemap notifications
- (AGSPortalItem *) basemapPortalItem;
- (EQSBasemapType) basemapType;
@end

#endif
