//
//  AGSPoint+GeneralUtilities.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSPoint+GeneralUtilities.h"
#import "EDNLiteHelper.h"

@implementation AGSPoint (GeneralUtilities)
+ (AGSPoint *) pointFromLat:(double)latitude Long:(double)longitude
{
	return [EDNLiteHelper getWebMercatorAuxSpherePointFromLat:latitude Long:longitude];
}
@end
