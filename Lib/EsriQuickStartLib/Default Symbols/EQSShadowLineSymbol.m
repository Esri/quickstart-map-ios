//
//  EQSShadowLineSymbol.m
//  EsriQuickStart Framework
//
//  Created by Nicholas Furness on 11/27/12.
//
//

#import "EQSShadowLineSymbol.h"

@implementation EQSShadowLineSymbol
// TODO: Find out another way to do this at 10.1.1
//+ (EQSShadowLineSymbol *) simpleLineSymbolWithColor:(UIColor *)color width:(double)width
//{
//    EQSShadowLineSymbol *result = [[EQSShadowLineSymbol alloc] init];
//    result.color = color;
//    result.width = width;
//    return result;
//}
//
//- (void) applySymbolToContext:(CGContextRef)context withGraphic:(AGSGraphic *)graphic
//{
//    [super applySymbolToContext:context withGraphic:graphic];
//    
//    CGColorRef shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.8f] CGColor];
//    
//    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, CGSizeMake(1.5,1.5), 1.5, shadowColor);
//}
@end

