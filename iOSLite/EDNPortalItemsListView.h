//
//  EDNBasemapsListView.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDNPortalItemsListViewController.h"

#define kEDNLiteNotification_BasemapSelected @"BasemapSelected"

@interface EDNPortalItemsListView : UIScrollView
@property (strong, nonatomic) IBOutlet EDNPortalItemsListViewController *viewController;

- (AGSPortalItem *) addPortalItem:(NSString *)portalItemID;
@end
