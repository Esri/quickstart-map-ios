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
    EDNLiteBasemapStreet,
    EDNLiteBasemapSatellite,
    EDNLiteBasemapHybrid,
    EDNLiteBasemapCanvas,
    EDNLiteBasemapNationalGeographic,
    EDNLiteBasemapTopographic,
    EDNLiteBasemapOpenStreetMap,
    
    EDNLiteBasemapFirst = EDNLiteBasemapStreet,
    EDNLiteBasemapLast = EDNLiteBasemapOpenStreetMap
} EDNLiteBasemapType;

#endif
