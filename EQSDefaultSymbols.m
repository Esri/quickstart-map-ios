//
//  EQSDefaultSymbols.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSDefaultSymbols.h"

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
#define kEQSCircleSize CGSizeMake(20,20)

@implementation AGSMapView (EQSDisplay)
EQSDefaultSymbols *__eqsDefaultSymbols = nil;

- (EQSDefaultSymbols *) defaultSymbols
{
    if (!__eqsDefaultSymbols)
    {
        __eqsDefaultSymbols = [[EQSDefaultSymbols alloc] init];
    }
    
    return __eqsDefaultSymbols;
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
    [self waitUntilLoaded];
    return _geolocation;
}

- (AGSMarkerSymbol *)findPlace
{
    [self waitUntilLoaded];
    return _geocode;
}

- (AGSMarkerSymbol *)reverseGeocode
{
    [self waitUntilLoaded];
    return _reverseGeocode;
}

- (AGSMarkerSymbol *)failedGeocode
{
    [self waitUntilLoaded];
    return _failedGeocode;
}

- (AGSSimpleLineSymbol *)route
{
    [self waitUntilLoaded];
    return _route;
}

- (AGSMarkerSymbol *)routeStart
{
    [self waitUntilLoaded];
    return _routeStart;
}

- (AGSMarkerSymbol *)routeEnd
{
    [self waitUntilLoaded];
    return _routeEnd;
}

- (AGSSimpleLineSymbol *)routeSegment
{
    [self waitUntilLoaded];
    return _routeSegment;
}

- (AGSMarkerSymbol *)routeSegmentStart
{
    [self waitUntilLoaded];
    return _routeSegmentStart;
}



- (void)waitUntilLoaded
{
    if (self.loadingQueue)
    {
        NSLog(@"Waiting for Default Symbols to load…");
        [self.loadingQueue waitUntilAllOperationsAreFinished];
        self.loadingQueue = nil;
        NSLog(@"Default Symbols loaded…");
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
    if (self.loadingQueue)
    {
        if (self.loadingQueue == object)
        {
            if (self.loadingQueue.operationCount == 0)
            {
                // Death to L'NSOperation! Down with that sort of thing.
                self.loadingQueue = nil;
                NSLog(@"Cleaned up after Symbol Load");
            }
        }
    }
}

- (void) populateSymbols
{
    self.geolocation = [self getPinSizedPictureMarkerSymbolForURL:kEQSBluePinURL];
    
    self.route = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7f]
                                                          width:8.0f];
    self.routeStart = [self getPinSizedPictureMarkerSymbolForURL:kEQSGreenPinURL];
    self.routeEnd = [self getPinSizedPictureMarkerSymbolForURL:kEQSRedPinURL];
    
    self.routeSegmentStart = [self getCircleSizedPictureMarkerSymbolForURL:kEQSGreenCircleURL];
    self.routeSegment = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[[UIColor greenColor] colorWithAlphaComponent:0.5f]
                                                                 width:10.0f];
    
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