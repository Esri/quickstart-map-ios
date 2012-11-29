//
//  AGSGraphicsLayer+EQSGraphics.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 7/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSGraphicsLayer (EQSGraphics)
- (void) addGraphic:(AGSGraphic *)graphic withID:(NSString *)graphicID;
- (AGSGraphic *) getGraphicForID:(NSString *)graphicID;

// Shortcut to populate the AGSGraphic.attributes dictionary with a key/value
// See also removeGraphicsByAttribute:withValue
- (void) addGraphic:(AGSGraphic *)graphic withAttribute:(id)attribute withValue:(id)value;

// Remove graphics by matching some criteria. The NSSet will contain AGSGraphicsLayers that were updated.
- (NSSet *) removeGraphicsMatchingCriteria:(BOOL(^)(AGSGraphic *graphic))checkBlock;
// See also addGraphic:withAttribute:withValue
- (NSSet *) removeGraphicsByAttribute:(id)attribute withValue:(id)value;
// Also just using a standard ID field
- (NSSet *) removeGraphicsByID:(NSString *)graphicID;
@end
