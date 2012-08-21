//
//  EQSRouteResultsTableViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGSRouteResult;

@interface EQSRouteResultsTableViewController : UITableViewController
@property (nonatomic, strong) AGSRouteResult *routeResult;
@end
