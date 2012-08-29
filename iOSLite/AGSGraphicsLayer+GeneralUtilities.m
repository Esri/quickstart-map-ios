//
//  AGSGraphicsLayer+GeneralUtilities.m
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 7/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSGraphicsLayer+GeneralUtilities.h"

@implementation AGSGraphicsLayer (EQSGeneral)
#define kEQSGraphicsLayerIDAttribute @"EQSGraphicID"

- (void) addGraphic:(AGSGraphic *)graphic withID:(NSString *)graphicID
{
    if (graphic.attributes == nil)
    {
        graphic.attributes = [NSMutableDictionary dictionary];
    }
    [graphic.attributes setObject:graphicID forKey:kEQSGraphicsLayerIDAttribute];
    [self addGraphic:graphic];
}

- (AGSGraphic *)getGraphicForID:(NSString *)graphicID
{
    for (AGSGraphic *g in self.graphics) {
        NSString *gID = [g.attributes objectForKey:kEQSGraphicsLayerIDAttribute];
        if (!(gID == nil || [gID isKindOfClass:[NSNull class]]))
        {
            if ([gID isEqualToString:graphicID])
            {
                return g;
            }
        }
    }
    return nil;
}

- (void) addGraphic:(AGSGraphic *)graphic withAttribute:(id)attribute withValue:(id)value
{
    if (!graphic.attributes)
    {
        graphic.attributes = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [graphic.attributes setObject:value forKey:attribute];
    [self addGraphic:graphic];
    [self dataChanged];
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
    
    [self dataChanged];
    
    return graphicsToRemove;
}

- (NSSet *) removeGraphicsByAttribute:(id)attribute withValue:(id)value
{
    return [self removeGraphicsMatchingCriteria:^BOOL(AGSGraphic *graphic) {
        return [[graphic.attributes objectForKey:attribute] isEqual:value];
    }];
}

@end
