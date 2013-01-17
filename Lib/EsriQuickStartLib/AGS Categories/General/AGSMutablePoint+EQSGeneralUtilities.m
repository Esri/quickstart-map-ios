//
//  AGSMutablePoint+EQSGeneralUtilities.m
//  EsriQuickStartLib
//
//  Created by Nicholas Furness on 1/16/13.
//
//

#import "AGSMutablePoint+EQSGeneralUtilities.h"
#import "AGSPoint+EQSGeneralUtilities.h"

@implementation AGSMutablePoint (EQSGeneralUtilities)
-(void) updateWithLat:(double)latitude lon:(double)longitude
{
    AGSPoint *temp = [AGSPoint pointFromLat:latitude lon:longitude];
    AGSPoint *projectedTemp = (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:temp toSpatialReference:self.spatialReference];
    [self updateWithX:projectedTemp.x y:projectedTemp.y];
}
@end
