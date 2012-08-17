//
//  EQSPortalItemPickerView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@protocol EQSPortalItemPickerDelegate
@optional
-(void) currentPortalItemChanged:(AGSPortalItem *)currentPortalItem;
-(void) basemapsPickerDidTapInfoButton:(id)basemapsPicker;
@end

@interface EQSPortalItemPickerView : UIView {
	id<EQSPortalItemPickerDelegate> pickerDelegate;
}

@property (nonatomic, assign) id pickerDelegate;

@property (nonatomic, weak) NSString *currentPortalItemID;
@property (nonatomic, strong, readonly) AGSPortalItem *currentPortalItem;

- (AGSPortalItem *)addPortalItemByID:(NSString *)portalItemID;
- (void)ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight;
@end
