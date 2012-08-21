//
//  EQSRouteResultsViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface EQSRouteResultsViewController : UIViewController
@property (nonatomic, strong) AGSRouteResult *routeResult;
@property (nonatomic, assign) BOOL hidden;
@end
