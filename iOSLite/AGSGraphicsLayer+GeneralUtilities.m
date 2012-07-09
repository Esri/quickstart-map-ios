//
//  AGSGraphicsLayer+GeneralUtilities.m
//  iOSLite
//
//  Created by Nicholas Furness on 7/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSGraphicsLayer+GeneralUtilities.h"

@implementation AGSGraphicsLayer (GeneralUtilities)
#define kEDNLiteGraphicsLayerIDAttribute @"EDNLiteGraphicID"

- (void) addGraphic:(AGSGraphic *)graphic withID:(NSString *)graphicID
{
    if (graphic.attributes == nil)
    {
        graphic.attributes = [NSMutableDictionary dictionary];
    }
    [graphic.attributes setObject:graphicID forKey:kEDNLiteGraphicsLayerIDAttribute];
    [self addGraphic:graphic];
}

- (AGSGraphic *)getGraphicForID:(NSString *)graphicID
{
    for (AGSGraphic *g in self.graphics) {
        NSString *gID = [g.attributes objectForKey:kEDNLiteGraphicsLayerIDAttribute];
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
@end
