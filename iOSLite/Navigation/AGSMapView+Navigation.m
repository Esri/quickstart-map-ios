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
//        NSDictionary *context = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                                     [NSNumber numberWithDouble:latitude], @"latitude",
//                                                                     [NSNumber numberWithDouble:longitude], @"longitude",
//                                                                     [NSNumber numberWithInt:scaleLevel], @"scaleLevel", nil]
//                                                            forKey:@"zoomToScale"];
//        [self addObserver:self forKeyPath:@"loaded" options:NSKeyValueObservingOptionNew context:(__bridge_retained void *)context];
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

//- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if (object == self)
//    {
//        if (keyPath == @"loaded" && self.loaded)
//        {
//            NSDictionary *paramsPackage = (__bridge_transfer NSDictionary *)context;
//            if ([paramsPackage objectForKey:@"zoomToScale"])
//            {
//                NSDictionary *params = [paramsPackage objectForKey:@"zoomToScale"];
//                double lat = [[params objectForKey:@"latitude"] doubleValue];
//                double lon = [[params objectForKey:@"longitude"] doubleValue];
//                int scaleLevel = [[params objectForKey:@"scaleLevel"] intValue];
//                [self zoomToLat:lat Long:lon withScaleLevel:scaleLevel];
//            }
//        }    
//    }
//}
@end