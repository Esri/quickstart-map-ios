//
//  EDNBasemapItemViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNLiteBasemaps.h"

@interface EDNBasemapItemViewController : UIViewController
@property (nonatomic, strong, readonly) AGSPortalItem *portalItem;
@property (nonatomic, assign, readonly) EDNLiteBasemapType basemapType;
@property (nonatomic, assign) BOOL highlighted;

- (id)initWithPortalItemID:(NSString *)portalItemID forBasemapType:(EDNLiteBasemapType)basemapType;
@end
