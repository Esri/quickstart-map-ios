//
//  AGSMapView+Routing.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (Routing)
// Show route task results on the map
- (AGSGraphic *) showRouteResults:(AGSRouteTaskResult *)routeTaskResults;

// Clear the route from the map.
- (void) clearRoute;

// Properties
- (AGSSymbol *) routeStartSymbol;
- (AGSSymbol *) routeStopSymbol;
- (AGSSymbol *) routeSymbol;

- (void) setRouteStartSymbol:(AGSMarkerSymbol *)routeStartSymbol;
- (void) setRouteStopSymbol:(AGSMarkerSymbol *)routeStopSymbol;
- (void) setRouteSymbol:(AGSSimpleLineSymbol *)routeSymbol;
@end
