//
//  EQSRouteResultsTableViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AGSRouteResult;
@class AGSDirectionGraphic;

@protocol EQSRouteDisplayTableViewDelegate <NSObject>
- (void) direction:(AGSDirectionGraphic *)direction selectedFromRouteResult:(AGSRouteResult *)routeResult;
@end

@interface EQSRouteResultsTableViewController : UITableViewController
@property (nonatomic, strong) AGSRouteResult *routeResult;
@property (nonatomic, assign) id<EQSRouteDisplayTableViewDelegate> directionsDelegate;
@end
