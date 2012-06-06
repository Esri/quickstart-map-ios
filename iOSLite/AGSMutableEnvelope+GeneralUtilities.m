//
//  AGSMutableEnvelope+GeneralUtilities.m
//  iOSLite
//
//  Created by Nicholas Furness on 6/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMutableEnvelope+GeneralUtilities.h"

@implementation AGSMutableEnvelope (GeneralUtilities)
+ (AGSMutableEnvelope *)envelopeFromEnvelope:(AGSEnvelope *)envelope
{
    return [AGSMutableEnvelope envelopeWithXmin:envelope.xmin
                                           ymin:envelope.ymin
                                           xmax:envelope.xmax
                                           ymax:envelope.ymax
                               spatialReference:envelope.spatialReference];
}
@end