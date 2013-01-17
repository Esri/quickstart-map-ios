//
//  AGSMutablePoint+EQSGeneralUtilities.h
//  EsriQuickStartLib
//
//  Created by Nicholas Furness on 1/16/13.
//
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMutablePoint (EQSGeneralUtilities)
-(void) updateWithLat:(double)latitude lon:(double)longitude;
@end
