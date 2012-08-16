//
//  STXPortalItemListView.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STXPortalItemListViewController.h"

#define kSTXNotification_BasemapSelected @"BasemapSelected"

@interface STXPortalItemListView : UIScrollView
@property (strong, nonatomic) IBOutlet STXPortalItemListViewController *viewController;

- (AGSPortalItem *) addPortalItem:(NSString *)portalItemID;
@end
