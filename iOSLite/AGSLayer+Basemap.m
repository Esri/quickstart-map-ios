//
//  AGSLayer+Basemap.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/30/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSLayer+Basemap.h"

@implementation AGSLayer (Basemap)
BOOL __ednLiteIsBasemapLayer = NO;

- (BOOL) isEDNLiteBasemapLayer
{
    return __ednLiteIsBasemapLayer;
}

- (void) setIsEDNLiteBasemapLayer:(BOOL)isBasemapLayer
{
    __ednLiteIsBasemapLayer = isBasemapLayer;
}
@end
