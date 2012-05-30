//
//  AGSLayer+Basemap.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/30/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSLayer (Basemap)
- (BOOL) isEDNLiteBasemapLayer;
- (void) setIsEDNLiteBasemapLayer:(BOOL)isBasemapLayer;
@end
