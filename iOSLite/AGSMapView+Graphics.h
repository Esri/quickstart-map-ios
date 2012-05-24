//
//  AGSMapView+Graphics.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNLiteHelper.h"

@interface AGSMapView (Graphics)
- (AGSGraphic *) addPointAtLat:(double)latitude Long:(double)longitude;
- (AGSGraphic *) addLineWithLatsAndLongs:(NSNumber *) firstLatitude, ... NS_REQUIRES_NIL_TERMINATION;
- (void) initGraphics;
@end
