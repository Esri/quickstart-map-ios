//
//  EQSAddressCandidateViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "EQSAddressCandidateBaseViewController.h"

//@class EQSAddressCandidateView;
//@class EQSAddressCandidatePanelViewController;

@interface EQSAddressCandidatePanelViewController : EQSAddressCandidateBaseViewController
- (void) addToScrollView:(UIScrollView *)parentView;
- (UIScrollView *) removeFromParentScrollView;
- (void) ensureVisibleInParentUIScrollView;
- (void) sizeParentScrollView;
@property (nonatomic, readonly) CGRect nextPosition;
@end