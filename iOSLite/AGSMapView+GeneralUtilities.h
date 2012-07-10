//
//  AGSMapView+GeneralUtilities.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "AGSStarterGeoServices.h"

@interface AGSMapView (GeneralUtilities)
- (AGSLayer *) getLayerForName:(NSString *)layerName;
- (AGSStarterGeoServices *) geoServices;
@end
