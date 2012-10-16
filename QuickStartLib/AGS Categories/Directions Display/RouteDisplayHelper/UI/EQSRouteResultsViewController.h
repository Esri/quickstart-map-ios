//
//  EQSRouteResultsViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "EQSRouteResultsView.h"

@protocol EQSRouteDisplayViewDelegate <NSObject>
- (void) direction:(AGSDirectionGraphic *)direction selectedFromRouteResult:(AGSRouteResult *)routeResult;
- (void) zoomToRouteResult;
- (void) clearRouteResult;
- (void) editRoute;
@end

@interface EQSRouteResultsViewController : UIViewController
@property (nonatomic, strong) AGSMapView *mapView;
@property (nonatomic, strong) AGSRouteResult *routeResult;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, weak) id<EQSRouteDisplayViewDelegate> routeDisplayDelegate;
@end
