//
//  AGSPoint+GeneralUtilities.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSPoint (GeneralUtilities)
+ (AGSPoint *) pointFromLat:(double)latitude Long:(double)longitude;
@end
