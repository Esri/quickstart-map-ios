//
//  EQSPortalItemView.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

typedef enum {
    EQSPortalItemViewLoadingStateNew,
    EQSPortalItemViewLoadingStatePortalLoading,
    EQSPortalItemViewLoadingStatePortalLoaded,
    EQSPortalItemViewLoadingStatePortalItemLoading,
    EQSPortalItemViewLoadingStatePortalItemLoaded,
    EQSPortalItemViewLoadingStatePortalItemLoadedWithThumbnail
} EQSPortalItemViewLoadingState;

@class EQSPortalItemViewController;

@interface EQSPortalItemView : UIView
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, strong) IBOutlet EQSPortalItemViewController *viewController;

@property (nonatomic, readonly) NSString *portalItemID;
@property (nonatomic, readonly) AGSPortalItem *portalItem;
@property (nonatomic, readonly) EQSPortalItemViewLoadingState loadingState;
@end
