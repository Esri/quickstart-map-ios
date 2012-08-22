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

#define kEQSPinXOffset 0
#define kEQSPinYOffset 11
#define kEQSPinSize CGSizeMake(28,28)

#define kEQSGreenCircleURL @"http://static.arcgis.com/images/Symbols/Shapes/GreenCircleLargeB.png"
#define kEQSCircleXOffset 0
#define kEQSCircleYOffset 0
#define kEQSCircleSize CGSizeMake(14,14)

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

@synthesize geocode = _geocode;
@synthesize reverseGeocode = _reverseGeocode;

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

- (AGSMarkerSymbol *)geocode
{
    [self waitUntilLoaded];
    return _geocode;
}

- (AGSMarkerSymbol *)reverseGeocode
{
    [self waitUntilLoaded];
    return _reverseGeocode;
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
        [self.loadingQueue addOperation:op];
    }
    return self;
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
    
    self.geocode = [self getPinSizedPictureMarkerSymbolForURL:kEQSOrangePinURL];
    self.reverseGeocode = [self getPinSizedPictureMarkerSymbolForURL:kEQSYellowPinURL];
}
                            
- (AGSPictureMarkerSymbol *)pictureMarkerSymbol:(NSString *)url
{
    AGSPictureMarkerSymbol *pms = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]];
    return pms;
}

- (AGSPictureMarkerSymbol *) getPinSizedPictureMarkerSymbolForURL:(NSString *)url
{
    AGSPictureMarkerSymbol *pms = [self pictureMarkerSymbol:url];
    pms = [self pictureMarkerSymbol:url];
    pms.xoffset = kEQSPinXOffset;
    pms.yoffset = kEQSPinYOffset;
    pms.size = kEQSPinSize;
    
    return pms;
}

- (AGSPictureMarkerSymbol *) getCircleSizedPictureMarkerSymbolForURL:(NSString *)url
{
    AGSPictureMarkerSymbol *pms = [self pictureMarkerSymbol:url];
    pms = [self pictureMarkerSymbol:url];
    pms.xoffset = kEQSCircleXOffset;
    pms.yoffset = kEQSCircleYOffset;
    pms.size = kEQSCircleSize;
    
    return pms;
}
@end
