//
//  EQSDefaultSymbols.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSDefaultSymbols.h"
#import <objc/runtime.h>

#define kEQSBluePinURL @"http://static.arcgis.com/images/Symbols/Shapes/BluePin1LargeB.png"
#define kEQSGreenPinURL @"http://static.arcgis.com/images/Symbols/Shapes/GreenPin1LargeB.png"
#define kEQSRedPinURL @"http://static.arcgis.com/images/Symbols/Shapes/RedPin1LargeB.png"
#define kEQSYellowPinURL @"http://static.arcgis.com/images/Symbols/Shapes/YellowPin1LargeB.png"
#define kEQSOrangePinURL @"http://static.arcgis.com/images/Symbols/Shapes/OrangePin1LargeB.png"
#define kEQSBlackPinURL @"http://static.arcgis.com/images/Symbols/Shapes/BlackPin1LargeB.png"

#define kEQSPinXOffset 0
#define kEQSPinYOffset 14
#define kEQSPinSize CGSizeMake(28,28)

#define kEQSGreenCircleURL @"http://static.arcgis.com/images/Symbols/Shapes/GreenCircleLargeB.png"
#define kEQSCircleXOffset 0
#define kEQSCircleYOffset 0
#define kEQSCircleSize CGSizeMake(28,28)

@implementation AGSMapView (EQSDisplay)
#define kEQSDefaultSymbolsHelperKey @"EQSDefaultSymbolsHelper"

- (EQSDefaultSymbols *) defaultSymbols
{
    EQSDefaultSymbols *helper = objc_getAssociatedObject(self, kEQSDefaultSymbolsHelperKey);
    if (helper == nil)
    {
        helper = [[EQSDefaultSymbols alloc] init];
        objc_setAssociatedObject(self, kEQSDefaultSymbolsHelperKey, helper, OBJC_ASSOCIATION_RETAIN);
    }
    return helper;
}

@end

@interface EQSDefaultSymbols ()
@property (nonatomic, retain) NSOperationQueue *loadingQueue;
@end

@implementation EQSDefaultSymbols

@synthesize geolocation = _geolocation;

@synthesize findPlace = _geocode;
@synthesize reverseGeocode = _reverseGeocode;
@synthesize failedGeocode = _failedGeocode;

@synthesize route = _route;
@synthesize routeStart = _routeStart;
@synthesize routeEnd = _routeEnd;

@synthesize routeSegment = _routeSegment;
@synthesize routeSegmentStart = _routeSegmentStart;

@synthesize loadingQueue = _loadingQueue;

- (AGSMarkerSymbol *)geolocation
{
    if (!_geolocation) {
        [self waitUntilLoaded];
    }
    return _geolocation;
}

- (AGSMarkerSymbol *)findPlace
{
    if (!_geocode) {
        [self waitUntilLoaded];
    }
    return _geocode;
}

- (AGSMarkerSymbol *)reverseGeocode
{
    if (!_reverseGeocode) {
        [self waitUntilLoaded];
    }
    return _reverseGeocode;
}

- (AGSMarkerSymbol *)failedGeocode
{
    if (!_failedGeocode) {
        [self waitUntilLoaded];
    }
    return _failedGeocode;
}

- (AGSSimpleLineSymbol *)route
{
    if (!_route) {
        [self waitUntilLoaded];
    }
    return _route;
}

- (AGSMarkerSymbol *)routeStart
{
    if (!_routeStart) {
        [self waitUntilLoaded];
    }
    return _routeStart;
}

- (AGSMarkerSymbol *)routeEnd
{
    if (!_routeEnd) {
        [self waitUntilLoaded];
    }
    return _routeEnd;
}

- (AGSSimpleLineSymbol *)routeSegment
{
    if (!_routeSegment) {
        [self waitUntilLoaded];
    }
    return _routeSegment;
}

- (AGSMarkerSymbol *)routeSegmentStart
{
    if (!_routeSegmentStart) {
        [self waitUntilLoaded];
    }
    return _routeSegmentStart;
}



- (void)waitUntilLoaded
{
    if (self.loadingQueue &&
        self.loadingQueue.operationCount > 0)
    {
//        NSLog(@"Waiting for Default Symbols to load…");
//        NSLog(@"%@",[NSThread callStackSymbols]);
        [self.loadingQueue waitUntilAllOperationsAreFinished];
//        NSLog(@"Finished Waiting for Symbols to load");
    }
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.loadingQueue = [[NSOperationQueue alloc] init];
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"Loading symbols in background…");
            [self populateSymbols];
            NSLog(@"Symbols loaded");
        }];
        op.queuePriority = NSOperationQueuePriorityNormal;
        // When the symbols have finished loading, let's delete the OperationQueue
        [self.loadingQueue addObserver:self
                            forKeyPath:@"operationCount"
                               options:NSKeyValueObservingOptionNew context:nil];
        
        // And fire off a background task to load the symbols. Vive L'NSOperation!!
        [self.loadingQueue addOperation:op];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    NSLog(@"operationCount Changed");
    if (self.loadingQueue)
    {
        if (self.loadingQueue == object)
        {
            if (self.loadingQueue.operationCount == 0)
            {
                // This could come through on any thread, but we could be waiting in waitUntilLoaded
                // on the main UI thread.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.loadingQueue waitUntilAllOperationsAreFinished];
                    [self.loadingQueue removeObserver:self forKeyPath:@"operationCount"];
                    self.loadingQueue = nil;
                    NSLog(@"Cleaned up after Symbol Load");
                }];
            }
        }
    }
}

- (void) populateSymbols
{
    // Where we modify a symbol once it's returned, we must do so on the iVar since we've
    // written the property getters to block on this thread...
    self.geolocation = [self getPinSizedPictureMarkerSymbolForURL:kEQSBluePinURL];
    
    self.route = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7f]
                                                          width:6.0f];
    _route.lineCap = kCGLineCapRound;
    _route.lineJoin = kCGLineJoinRound;

    self.routeStart = [self getPinSizedPictureMarkerSymbolForURL:kEQSGreenPinURL];
    self.routeEnd = [self getPinSizedPictureMarkerSymbolForURL:kEQSRedPinURL];
    
    self.routeSegmentStart = [self getCircleSizedPictureMarkerSymbolForURL:kEQSGreenCircleURL];
    self.routeSegment = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[[UIColor greenColor] colorWithAlphaComponent:0.5f]
                                                                 width:10.0f];
    
    _routeSegment.lineCap = kCGLineCapRound;
    _routeSegment.lineJoin = kCGLineJoinRound;
    
    self.findPlace = [self getPinSizedPictureMarkerSymbolForURL:kEQSOrangePinURL];
    self.reverseGeocode = [self getPinSizedPictureMarkerSymbolForURL:kEQSYellowPinURL];
    self.failedGeocode = [self getPinSizedPictureMarkerSymbolForURL:kEQSBlackPinURL];
}
                            
- (AGSPictureMarkerSymbol *)pictureMarkerSymbol:(NSString *)url
{
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]];
    return pms;
}

- (AGSPictureMarkerSymbol *) getPinSizedPictureMarkerSymbolForURL:(NSString *)url
{
    AGSPictureMarkerSymbol *pms = [self pictureMarkerSymbol:url];
    pms.xoffset = kEQSPinXOffset;
    pms.yoffset = kEQSPinYOffset;
    pms.size = kEQSPinSize;
    pms.hotspot = CGPointMake(-pms.xoffset, -pms.yoffset);
    
    return pms;
}

- (AGSPictureMarkerSymbol *) getCircleSizedPictureMarkerSymbolForURL:(NSString *)url
{
    AGSPictureMarkerSymbol *pms = [self pictureMarkerSymbol:url];
    pms.xoffset = kEQSCircleXOffset;
    pms.yoffset = kEQSCircleYOffset;
    pms.size = kEQSCircleSize;
    pms.hotspot = CGPointMake(-pms.xoffset, -pms.yoffset);
    
    return pms;
}
@end