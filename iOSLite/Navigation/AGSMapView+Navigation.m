//
//  AGSMapView+LiteNavigation.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Navigation.h"
#import "EDNLiteHelper.h"

@implementation AGSMapView (Navigation)
// PUBLIC
- (void) zoomToLat:(double) latitude Long:(double) longitude withScaleLevel:(int)scaleLevel
{
    AGSPoint *webMercatorCenterPt = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    double scale = [EDNLiteHelper getScaleForLevel:scaleLevel];
    if (self.loaded)
    {
        NSLog(@"Loaded");
        [self zoomToScale:scale withCenterPoint:webMercatorCenterPt animated:YES];
    }
    else 
    {
        NSLog(@"Not Loaded: %d", self.loaded);
        [EDNLiteHelper queueBlock:^{
            [self zoomToScale:scale withCenterPoint:webMercatorCenterPt animated:YES];
        } untilMapViewLoaded:self];
    }
}

- (void) centerAtLat:(double) latitude Long:(double) longitude
{
    AGSPoint *p = [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
    [self centerAtPoint:p animated:YES];
}
@end