//
//  EQSPortalItemViewController.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EQSPortalItemView.h"

@protocol PortalItemViewTouchDelegate <NSObject>
-(void)portalItemViewTapped:(EQSPortalItemView *)portalItemView;
@end

@interface EQSPortalItemViewController : UIViewController
@property (nonatomic, weak) id<PortalItemViewTouchDelegate> touchDelegate;

@property (nonatomic, strong, readonly) AGSPortalItem *portalItem;
@property (nonatomic, strong, readonly) NSString *portalItemID;

@property (strong, nonatomic) IBOutlet EQSPortalItemView *portalItemView;

@property (nonatomic, readonly) EQSPortalItemViewLoadingState loadingState;

- (id) initWithPortalItemID:(NSString *)portalItemID;
@end
