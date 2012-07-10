//
//  AGSMapView+GeneralUtilities.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+GeneralUtilities.h"

@implementation AGSMapView (GeneralUtilities)
AGSStarterGeoServices *__agsStarterGeoServices = nil;

- (AGSStarterGeoServices *) geoServices
{
	if (!__agsStarterGeoServices)
	{
		__agsStarterGeoServices = [[AGSStarterGeoServices alloc] init];
	}
	return __agsStarterGeoServices;
}


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
@end
