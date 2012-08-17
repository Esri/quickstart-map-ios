//
//  EQSPortalItemListViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol EQSPortalItemListViewDelegate
- (void)selectedPortalItemChanged:(AGSPortalItem *)selectedPortalItem;
@end

@interface EQSPortalItemListViewController : UIViewController {
	id <EQSPortalItemListViewDelegate> portalItemDelegate;
}

@property (nonatomic, weak) id portalItemDelegate;
@end
