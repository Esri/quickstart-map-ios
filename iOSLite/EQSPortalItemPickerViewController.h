//
//  EQSPortalItemPickerViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface EQSPortalItemPickerViewController : UIViewController
@property (nonatomic, weak) NSString *currentPortalItemID;
@property (nonatomic, strong) AGSPortalItem *currentPortalItem;

@property (nonatomic, assign) id delegate;

- (AGSPortalItem *)addPortalItemByID:(NSString *)portalItemID;
- (void)ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight;
@end
