//
//  EQSCodeView.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "EQSCodeViewController.h"

@interface EQSCodeView : UIView
@property (nonatomic, weak) IBOutlet AGSMapView *mapView;
@property (strong, nonatomic) IBOutlet EQSCodeViewController *viewController;
@end
