//  EQSHelper_int.h
//  EsriQuickStart
//
//  Created by Nicholas Furness on 5/22/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSHelper.h"

@interface EQSHelper ()
+ (NSBundle *) getEQSBundle;


// Queuing. Some operations cannot be performed until the AGSMapView has loaded.
// This single function takes a code block and only executes it once the provided
// AGSMapView enters a loaded state.
+ (void) queueBlock:(void (^)(void))block untilMapViewLoaded:(AGSMapView *)mapView;

@end
