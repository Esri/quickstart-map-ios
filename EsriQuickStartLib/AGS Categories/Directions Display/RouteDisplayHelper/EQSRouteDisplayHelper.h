//
//  EQSRouteDisplayHelper.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsViewController.h"

#define kEQSRouteDisplayNotification_RouteCleared @"EQSRouteDisplayNotificationRouteCleared"
#define kEQSRouteDisplayNotification_EditRequested @"EQSRouteDisplayNotificationEditRequested"
#define kEQSRouteDisplayNotification_StepSelected @"EQSRouteDisplayNotificationStepSelected"

@interface EQSRouteDisplayHelper : NSObject
// Use this method to instantiate a new RouteDisplayHelper for a given AGSMapView
+ (EQSRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView;

- (void) showRouteResult:(AGSRouteTaskResult *)routeTaskResult;
- (void) zoomToRouteResult;
- (void) clearRouteResult;

- (AGSGraphic *) setStartPoint:(AGSPoint *)startPoint;
- (AGSGraphic *) setEndPoint:(AGSPoint *)endPoint;

@property (nonatomic, retain, readonly) AGSRouteResult *currentRouteResult;

@property (nonatomic, retain) EQSRouteResultsViewController *routeResultsViewController;

@property (nonatomic, retain) AGSGraphicsLayer *routeGraphicsLayer;
@property (nonatomic, retain) AGSMarkerSymbol *startSymbol;
@property (nonatomic, retain) AGSMarkerSymbol *endSymbol;
@property (nonatomic, retain) AGSSimpleLineSymbol *routeSymbol;
@end