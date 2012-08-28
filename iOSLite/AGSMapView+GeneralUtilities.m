//
//  AGSMapView+GeneralUtilities.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+GeneralUtilities.h"
#import "EQSHelper.h"

@implementation AGSMapView (General)
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

- (AGSEnvelope *) getEnvelopeToFitViewAspectRatio:(AGSEnvelope *)sourceEnvelope
{
    double R = self.frame.size.width / self.frame.size.height;
    double r = sourceEnvelope.width / sourceEnvelope.height;
    
    AGSMutableEnvelope *dEnv = [sourceEnvelope mutableCopy];
    [dEnv reaspect:self.frame.size];
    
    double r2 = dEnv.width / dEnv.height;
    
    NSLog(@"AGSMapView: %f\nSource: %f\nEnd: %f", R, r, r2);
    
    return dEnv;
}

- (CGRect) getMinOrthoVisibleArea
{
    UIView *parent = self.superview;
    BOOL afterMe = NO;
    NSMutableArray *viewsVisibleOverMe = [NSMutableArray array];
    for (UIView *sibling in parent.subviews)
    {
        if (afterMe && !sibling.hidden && CGRectIntersectsRect(self.frame, sibling.frame))
        {
            [viewsVisibleOverMe addObject:sibling];
        }
        if (sibling == self) afterMe = YES;
    }
    
    CGRect workingFrame = self.frame;
    
    for (UIView *viewOverMe in viewsVisibleOverMe)
    {
        NSLog(@"Comparing %@", viewOverMe);
        NSLog(@"Working Frame Before: %@", NSStringFromCGRect(workingFrame));
        workingFrame = [self rectSubtract:viewOverMe.frame from:workingFrame];
        NSLog(@"Working Frame After: %@", NSStringFromCGRect(workingFrame));
    }
    
    return workingFrame;
}

- (CGRect) rectSubtract:(CGRect)rSub from:(CGRect)rMain
{
    CGRect intersection = CGRectIntersection(rMain, rSub);
    
    if (CGRectIsNull(intersection))
    {
        return rMain;
    }
    
    // Compare horizontally
    CGRect remX1, remX2, remY1, remY2, trash;
    
    CGRectDivide(rMain, &trash, &remX1, intersection.origin.x + intersection.size.width, CGRectMinXEdge);
    CGRectDivide(rMain, &trash, &remX2, rMain.origin.x + rMain.size.width - intersection.origin.x , CGRectMaxXEdge);
    CGRectDivide(rMain, &trash, &remY1, intersection.origin.y + intersection.size.height, CGRectMinYEdge);
    CGRectDivide(rMain, &trash, &remY2, rMain.origin.y + rMain.size.height - intersection.origin.y, CGRectMaxYEdge);
    
    double a1 = remX1.size.width * remX1.size.height;
    double maxA = a1;
    CGRect maxRect = remX1;
    double a2 = remX2.size.width * remX2.size.height;
    if (a2 > maxA) { maxRect = remX2; maxA = a2; };
    double a3 = remY1.size.width * remY1.size.height;
    if (a3 > maxA) { maxRect = remY1; maxA = a3; };
    double a4 = remY2.size.width * remY2.size.height;
    if (a4 > maxA) { maxRect = remY2; };
    
    return maxRect;
}
@end
