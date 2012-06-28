//
//  EDNLitRouteTaskHelper.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@protocol EDNLiteRouteTaskDelegate
- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult;
- (void) routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error;
@end

@interface EDNLiteRouteTaskHelper : NSObject<AGSRouteTaskDelegate>
+ (EDNLiteRouteTaskHelper *) ednLiteRouteTaskHelper;
- (void) setStart:(AGSPoint *)startPoint AndStop:(AGSPoint *)stopPoint;
- (AGSRouteTaskParameters *) getParameters;
- (AGSRouteTaskParameters *) getParametersToRouteFromStart:(AGSPoint *)startPoint ToStop:(AGSPoint *)stopPoint;

- (void) solveRouteWhenReady;

@property (nonatomic, assign) id<AGSRouteTaskDelegate> delegate;

@property (nonatomic, retain) AGSRouteTask *routeTask;
@property (nonatomic, retain) AGSRouteTaskParameters *defaultParameters;
@property (assign) BOOL loaded;

@property (nonatomic, retain) AGSGraphicsLayer *resultsGraphicsLayer;

@property (nonatomic, retain) AGSMarkerSymbol *startSymbol;
@property (nonatomic, retain) AGSMarkerSymbol *stopSymbol;
@property (nonatomic, retain) AGSSimpleLineSymbol *routeSymbol;
@end