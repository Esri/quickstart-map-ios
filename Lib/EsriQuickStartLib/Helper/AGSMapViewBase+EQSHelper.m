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
    // First of all we want to replace setDelegate and getDelegate with our own
    // methods. We'll still call them, but we want to creep into the call stack.
    Class swap = [self class];
    Method a = nil; Method b = nil;
    
    a = class_getInstanceMethod(swap, @selector(setLayerDelegate:));
    b = class_getInstanceMethod(swap, @selector(eqs_setLayerDelegate:));
    method_exchangeImplementations(a, b);
    
    a = class_getInstanceMethod(swap, @selector(layerDelegate));
    b = class_getInstanceMethod(swap, @selector(eqs_layerDelegate));
    method_exchangeImplementations(a, b);
}

-(void)eqs_setLayerDelegate:(id<AGSMapViewLayerDelegate>)layerDelegate
{
    // We store the externally visible delegate as an associate object…
    // Although we don't allow anyone to set EQSHelper's singleton as it…
    if (layerDelegate && layerDelegate != [EQSHelper defaultHelper])
    {
        objc_setAssociatedObject(self, kEQSInterceptedDelegate, layerDelegate, OBJC_ASSOCIATION_RETAIN);
    }
    else
    {
        objc_setAssociatedObject(self, kEQSInterceptedDelegate, nil, OBJC_ASSOCIATION_ASSIGN);
    }

    // But internally we set the delegate as the EQSHelper singleton.
    //
    // Note: Because of the method swizzling that happens on AGSMapView +load(), this is actually
    // the originally defined setLayerDelegate: method. Where we are now is by this point known as
    // AGSMapView->setLayerDelegate: - confusing, powerful, and neat.
    [self eqs_setLayerDelegate:[EQSHelper defaultHelper]];
}

-(id<AGSMapViewLayerDelegate>)eqs_layerDelegate
{
    // And whenever anyone asks for the delegate, we'll return the EQSHelper Singleton.
    //
    // When someone calls an <AGSMapViewLayerDelegate> protocol method, the EQSHelper
    // singleton will receive that call and marshall it to the actual externally visible
    // delegate, but in the case of mapViewDidLoad will raise a notification too.
    //
    // End result? Delegate model still works, but now we also have a notification when
    // the map view loaded.
    return [EQSHelper defaultHelper];
}
@end
