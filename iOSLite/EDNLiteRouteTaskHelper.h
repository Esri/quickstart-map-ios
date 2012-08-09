//
//  EDNLitRouteTaskHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface EDNLiteRouteTaskHelper : NSObject
+ (EDNLiteRouteTaskHelper *) ednLiteRouteTaskHelperForMapView:(AGSMapView *)mapView;

- (id) initForMapView:(AGSMapView *)mapView;

@property (nonatomic, retain) AGSGraphicsLayer *routeGraphicsLayer;

@property (nonatomic, retain) AGSMarkerSymbol *startSymbol;
@property (nonatomic, retain) AGSMarkerSymbol *endSymbol;
@property (nonatomic, retain) AGSSimpleLineSymbol *routeSymbol;
@end