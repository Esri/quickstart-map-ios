//
//  AGSMutableEnvelope+GeneralUtilities.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMutableEnvelope (GeneralUtilities)
+ (AGSMutableEnvelope *)envelopeFromEnvelope:(AGSEnvelope *)envelope;
@end
