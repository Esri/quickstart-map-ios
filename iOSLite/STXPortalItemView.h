//
//  STXPortalItemView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

typedef enum {
    STXPortalItemViewLoadingStateNew,
    STXPortalItemViewLoadingStatePortalLoading,
    STXPortalItemViewLoadingStatePortalLoaded,
    STXPortalItemViewLoadingStatePortalItemLoading,
    STXPortalItemViewLoadingStatePortalItemLoaded,
    STXPortalItemViewLoadingStatePortalItemLoadedWithThumbnail
} STXPortalItemViewLoadingState;

@class STXPortalItemViewController;

@interface STXPortalItemView : UIView
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, strong) IBOutlet STXPortalItemViewController *viewController;

@property (nonatomic, readonly) NSString *portalItemID;
@property (nonatomic, readonly) AGSPortalItem *portalItem;
@property (nonatomic, readonly) STXPortalItemViewLoadingState loadingState;
@end
