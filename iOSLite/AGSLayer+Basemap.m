//
//  AGSLayer+Basemap.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/30/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSLayer+Basemap.h"

@implementation AGSLayer (EQSBasemaps)
BOOL __eqsIsBasemapLayer = NO;

- (BOOL) isEQSBasemapLayer
{
    return __eqsIsBasemapLayer;
}

- (void) setIsEQSBasemapLayer:(BOOL)isBasemapLayer
{
    __eqsIsBasemapLayer = isBasemapLayer;
}
@end
