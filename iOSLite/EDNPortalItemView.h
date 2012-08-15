//
//  EDNPortalItemView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@class EDNPortalItemViewController;

@interface EDNPortalItemView : UIView
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, strong) IBOutlet EDNPortalItemViewController *viewController;

@property (nonatomic, readonly) NSString *portalItemID;
@property (nonatomic, readonly) AGSPortalItem *portalItem;
@end
