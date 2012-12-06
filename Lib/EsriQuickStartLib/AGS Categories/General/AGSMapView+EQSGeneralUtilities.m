//
//  AGSMapView+GeneralUtilities.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+EQSGeneralUtilities.h"
#import "EQSHelper_int.h"

@implementation AGSMapView (EQSGeneralUtilities)
- (AGSLayer *) getLayerForName:(NSString *)layerName
{
    for (AGSLayer *l in self.mapLayers) {
        if (l.name == layerName)
        {
            return l;
        }
    }
    return nil;
}


- (void) doActionWhenLoaded:(void (^)(void))actionBlock
{
    // The Action Block needs to wait until the MapView is loaded.
    // Let's see if we want to run it now, or need to queue it up until the AGSMapView is loaded.
    if (self.loaded)
    {
        // If the mapView is already loaded, just run this code.
        actionBlock();
    }
    else
    {
        // Otherwise we queue this block up to be run when self (an AGSMapView) *has* loaded
        // since the behaviour doesn't work before then. This is because the map will not yet
        // be fully initialized for UI interaction until then.
        [EQSHelper queueBlock:actionBlock untilMapViewLoaded:self];
    }
}
@end
