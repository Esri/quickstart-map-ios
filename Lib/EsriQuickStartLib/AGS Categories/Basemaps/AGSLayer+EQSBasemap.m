//
//  AGSLayer+Basemap.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 5/30/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSLayer+EQSBasemap.h"
#import <objc/runtime.h>

#define kEQSInternalLayerTag @"EQSLayerTag"
#define kEQSInternalLayerTag_Basemap @"Basemap"

@implementation AGSLayer (EQSBasemaps)
- (BOOL) isEQSBasemapLayer
{
    NSString *layerTag = objc_getAssociatedObject(self, kEQSInternalLayerTag);
    return [layerTag isEqualToString:kEQSInternalLayerTag_Basemap];
}

- (void) setIsEQSBasemapLayer:(BOOL)isBasemapLayer
{
    if (isBasemapLayer)
    {
        objc_setAssociatedObject(self, kEQSInternalLayerTag, kEQSInternalLayerTag_Basemap, OBJC_ASSOCIATION_RETAIN);
    }
    else
    {
        objc_setAssociatedObject(self, kEQSInternalLayerTag, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}
@end
