//
//  EQSGraphicCallout.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/29/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSGraphicCallout.h"
#import "EQSGraphicCalloutViewController.h"

@implementation EQSGraphicCallout
- (UIView *) customViewForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint
{
    EQSGraphicCalloutViewController *vc = [EQSGraphicCalloutViewController defaultVCForGraphic:graphic];
    return vc.view;
}
@end
