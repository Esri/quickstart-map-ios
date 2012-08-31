//
//  EQSGraphicCalloutVCViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/29/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGSGraphic;

@interface EQSGraphicCalloutViewController : UIViewController
+ (EQSGraphicCalloutViewController *)defaultVCForGraphic:(AGSGraphic *)graphic;
@end
