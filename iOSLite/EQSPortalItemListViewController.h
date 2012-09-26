//
//  EQSPortalItemListViewController.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol EQSPortalItemListViewDelegate <NSObject>
- (void)selectedPortalItemChanged:(AGSPortalItem *)selectedPortalItem;
@end

@interface EQSPortalItemListViewController : UIViewController
@property (nonatomic, weak) id<EQSPortalItemListViewDelegate> portalItemDelegate;
@end
