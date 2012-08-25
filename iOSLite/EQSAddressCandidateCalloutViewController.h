//
//  EQSAddressCandidateCalloutViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "EQSAddressCandidateCalloutView.h"

@interface EQSAddressCandidateCalloutViewController : UIViewController
@property (nonatomic, strong) AGSAddressCandidate *candidate;
@property (nonatomic, strong) AGSGraphic *graphic;
@end
