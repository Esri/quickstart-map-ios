//
//  EDNBasemapsPickerViewController.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol EDNBasemapsPickerUIDelegate
-(void) basemapsPicker:(id)basemapsPicker DidTapInfoButton:(AGSPortalItem *)portalItem;
@end

@interface EDNPortalItemsPickerViewController : UIViewController {
	id <EDNBasemapsPickerUIDelegate> delegate;
}

- (void)addPortalItemByID:(NSString *)portalItemID;
- (void)ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight;

@property (nonatomic, weak, readonly) AGSPortalItem * currentPortalItem;
@property (nonatomic, strong) id delegate;
@end
