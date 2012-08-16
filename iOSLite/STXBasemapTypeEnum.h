//
//  STXBasemapTypeEnum.h
//  iOSLite
//
//  Created by Nicholas Furness on 5/25/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#ifndef iOSLite_STXBasemapTypeEnum_h
#define iOSLite_STXBasemapTypeEnum_h

typedef enum {
    STXBasemapTypeStreet = 1,
    STXBasemapTypeSatellite = 2,
    STXBasemapTypeHybrid = 3,
    STXBasemapTypeCanvas = 4,
    STXBasemapTypeNationalGeographic = 5,
    STXBasemapTypeTopographic = 6,
    STXBasemapTypeOpenStreetMap = 7,
    
    STXBasemapTypeFirst = STXBasemapTypeStreet,
    STXBasemapTypeLast = STXBasemapTypeOpenStreetMap
} STXBasemapType;

#endif