//
//  STXPortalItemView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@class STXPortalItemViewController;

@interface STXPortalItemView : UIView
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, strong) IBOutlet STXPortalItemViewController *viewController;

@property (nonatomic, readonly) NSString *portalItemID;
@property (nonatomic, readonly) AGSPortalItem *portalItem;
@end
