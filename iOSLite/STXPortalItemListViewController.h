//
//  STXPortalItemListViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol STXPortalItemListViewDelegate
- (void)selectedPortalItemChanged:(AGSPortalItem *)selectedPortalItem;
@end

@interface STXPortalItemListViewController : UIViewController {
	id <STXPortalItemListViewDelegate> portalItemDelegate;
}

@property (nonatomic, weak) id portalItemDelegate;
@end
