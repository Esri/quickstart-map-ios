//
//  STXPortalItemViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "STXPortalItemView.h"

@protocol PortalItemViewTouchDelegate
-(void)portalItemViewTapped:(STXPortalItemView *)portalItemView;
@end

@interface STXPortalItemViewController : UIViewController {
	id<PortalItemViewTouchDelegate> touchDelegate;
}
@property (nonatomic, weak) id touchDelegate;

@property (nonatomic, strong, readonly) AGSPortalItem *portalItem;
@property (nonatomic, strong, readonly) NSString *portalItemID;

@property (strong, nonatomic) IBOutlet STXPortalItemView *portalItemView;

@property (nonatomic, readonly) STXPortalItemViewLoadingState loadingState;

- (id) initWithPortalItemID:(NSString *)portalItemID;
@end
