//
//  EDNBasemapsListView.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDNPortalItemViewController.h"

#define kEDNLiteNotification_BasemapSelected @"BasemapSelected"

@interface EDNPortalItemsListView : UIScrollView
- (void) addPortalItem:(NSString *)portalItemID;
- (void) ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight;
- (void) positionItemsInView;
@end
