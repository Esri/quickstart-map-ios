//
//  EQSCodeViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

#import "EQSSampleAppState.h"

@interface EQSCodeViewController : UIViewController
- (void) attachToRightEdgeOfMapView;
- (void) refreshCodeSnippetViewerPosition;

@property (nonatomic, assign) EQSSampleAppState currentAppState;
@end
