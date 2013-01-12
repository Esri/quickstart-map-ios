//
//  AGSMapViewBase+EQSHelper.m
//  EsriQuickStartLib
//
//  Created by Nicholas Furness on 1/11/13.
//
//

#import "AGSMapViewBase+EQSHelper.h"
#import "EQSHelper_int.h"
#import <objc/runtime.h>

@implementation AGSMapViewBase (EQSHelper)
+(void)load
{
    Class swap = [self class];
    Method a = nil; Method b = nil;
    
    a = class_getInstanceMethod(swap, @selector(setLayerDelegate:));
    b = class_getInstanceMethod(swap, @selector(eqs_setLayerDelegate:));
    method_exchangeImplementations(a, b);
    
    a = class_getInstanceMethod(swap, @selector(layerDelegate));
    b = class_getInstanceMethod(swap, @selector(eqs_layerDelegate));
    method_exchangeImplementations(a, b);

    NSLog(@"Swizzled %@", swap);
}

-(void)eqs_setLayerDelegate:(id<AGSMapViewLayerDelegate>)layerDelegate
{
    if (layerDelegate && layerDelegate != [EQSHelper defaultHelper])
    {
        objc_setAssociatedObject(self, kEQSInterceptedDelegate, layerDelegate, OBJC_ASSOCIATION_RETAIN);
    }
    else
    {
        objc_setAssociatedObject(self, kEQSInterceptedDelegate, nil, OBJC_ASSOCIATION_ASSIGN);
    }

    [self eqs_setLayerDelegate:[EQSHelper defaultHelper]];
    
    id hiddenDel = objc_getAssociatedObject(self, kEQSInterceptedDelegate);
    id pretendDel = [self layerDelegate];
    
    NSLog(@"Layer Delegate is: %@ and %@", hiddenDel, pretendDel);
}

-(id<AGSMapViewLayerDelegate>)eqs_layerDelegate
{
    NSLog(@"Someone asked for the layerDelegate");
    return [EQSHelper defaultHelper];
}
@end
