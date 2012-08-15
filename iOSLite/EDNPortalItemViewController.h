//
//  EDNBasemapItemViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/13/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNPortalItemView.h"

@protocol PortalItemViewTouchDelegate
-(void)portalItemViewTapped:(EDNPortalItemView *)portalItemView;
@end

@interface EDNPortalItemViewController : UIViewController {
	id<PortalItemViewTouchDelegate> touchDelegate;
}
@property (nonatomic, weak) id touchDelegate;

@property (nonatomic, strong, readonly) AGSPortalItem *portalItem;
@property (nonatomic, strong, readonly) NSString *portalItemID;

@property (strong, nonatomic) IBOutlet EDNPortalItemView *portalItemView;

- (id) initWithPortalItemID:(NSString *)portalItemID;
@end
