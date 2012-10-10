//
//  EQSCodeViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

#import "EQSSampleAppStateEnums.h"

@class EQSCodeViewController;

@protocol EQSCodeViewControllerDelegate <NSObject>
@optional
- (void) codeviewWantsToBeDismissed:(EQSCodeViewController *)codeviewController;
@end

@interface EQSCodeViewController : UIViewController
- (void) attachToRightEdgeOfMapView;
- (void) refreshCodeSnippetViewerPosition;

@property (nonatomic, assign) EQSSampleAppState currentAppState;
@property (nonatomic, strong) id<EQSCodeViewControllerDelegate> delegate;
@end
