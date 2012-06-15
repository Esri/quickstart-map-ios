//
//  EDNLiteBasemaps.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#ifndef iOSLite_EDNLiteBasemaps_h
#define iOSLite_EDNLiteBasemaps_h

typedef enum {
    EDNLiteBasemapStreet = 1,
    EDNLiteBasemapSatellite = 2,
    EDNLiteBasemapHybrid = 3,
    EDNLiteBasemapCanvas = 4,
    EDNLiteBasemapNationalGeographic = 5,
    EDNLiteBasemapTopographic = 6,
    EDNLiteBasemapOpenStreetMap = 7,
    
    EDNLiteBasemapFirst = EDNLiteBasemapStreet,
    EDNLiteBasemapLast = EDNLiteBasemapOpenStreetMap
} EDNLiteBasemapType;

#endif
