//
//  EQSRouteDisplayHelper.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class EQSRouteResultsViewController;

@interface EQSRouteDisplayHelper : NSObject
// Use this method to instantiate a new RouteDisplayHelper for a given AGSMapView
+ (EQSRouteDisplayHelper *) routeDisplayHelperForMapView:(AGSMapView *)mapView;

- (void) showRouteResult:(AGSRouteTaskResult *)routeTaskResult;
- (void) zoomToRouteResult;
- (void) clearRouteResult;

@property (nonatomic, retain) EQSRouteResultsViewController *tableVC;

@property (nonatomic, retain) AGSGraphicsLayer *routeGraphicsLayer;
@property (nonatomic, retain) AGSMarkerSymbol *startSymbol;
@property (nonatomic, retain) AGSMarkerSymbol *endSymbol;
@property (nonatomic, retain) AGSSimpleLineSymbol *routeSymbol;
@end