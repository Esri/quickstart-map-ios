//
//  AGSGraphicsLayer+GeneralUtilities.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 7/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSGraphicsLayer+EQSGraphics.h"

@implementation AGSGraphicsLayer (EQSGraphics)
#define kEQSGraphicsLayerIDAttribute @"EQSGraphicID"

- (void) addGraphic:(AGSGraphic *)graphic withID:(NSString *)graphicID
{
    [graphic setAttributeWithString:graphicID forKey:kEQSGraphicsLayerIDAttribute];
    [self addGraphic:graphic];
}

- (AGSGraphic *)getGraphicForID:(NSString *)graphicID
{
    for (AGSGraphic *g in self.graphics) {
        NSString *gID = [g attributeAsStringForKey:kEQSGraphicsLayerIDAttribute];
        if (!(gID == nil || gID == (id)[NSNull null]))
        {
            if ([gID isEqualToString:graphicID])
            {
                return g;
            }
        }
    }
    return nil;
}

- (void) addGraphic:(AGSGraphic *)graphic withAttribute:(NSString *)attribute withValue:(id)value
{
    [graphic setAttribute:value forKey:attribute];
    [self addGraphic:graphic];
}


- (NSSet *) removeGraphicsMatchingCriteria:(BOOL (^)(AGSGraphic *graphic))checkBlock
{
    // Get the graphics to remove from this layer
    NSMutableSet *graphicsToRemove = [NSMutableSet set];
    for (AGSGraphic *g in self.graphics) {
        if (checkBlock(g))
        {
            [graphicsToRemove addObject:g];
        }
    }
    
    // Remove each graphic from its layer, and remember the set of layers affected
    for (AGSGraphic *g in graphicsToRemove)
    {
        [self removeGraphic:g];
    }
    
    return graphicsToRemove;
}

- (NSSet *) removeGraphicsByAttribute:(NSString *)attribute withValue:(id)value
{
    return [self removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *graphic) {
        return [[graphic attributeForKey:attribute] isEqual:value];
    }];
}

- (NSSet *) removeGraphicsByID:(NSString *)graphicID
{
	return [self removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *graphic) {
		return [[graphic attributeAsStringForKey:kEQSGraphicsLayerIDAttribute] isEqualToString:graphicID];
	}];
}
@end
