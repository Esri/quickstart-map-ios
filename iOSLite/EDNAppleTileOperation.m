//
//  EDNAppleTileOperation.m
//  MapTest1
//
//  Created by Nicholas Furness on 3/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNAppleTileOperation.h"

@interface EDNAppleTileOperation ()
@end

@implementation EDNAppleTileOperation

@synthesize tile = _tile;
@synthesize target = _target;
@synthesize action = _action;

NSString *_urlTemplate = @"http://gsp2.apple.com/tile?api=1&style=slideshow&layers=default&lang=en_EN&z=%d&x=%d&y=%d&v=9";

- (id)initWithTile:(AGSTile *)tile target:(id)target action:(SEL)action
{
    if (self = [super init]) {
        self.action = action;
        self.target = target;
        self.tile = tile;
    }
    
    return self;
}

-(void)main {
    @try {
        // Get the tile from Apple's service.
        NSString *urlString = [NSString stringWithFormat:_urlTemplate, self.tile.level, self.tile.column, self.tile.row];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        _tile.image = [UIImage imageWithData:imageData];
    }
    @catch (NSException *exception) {
        NSLog(@"main: Caught Exception %@: %@", exception.name, exception.reason);
    }
    @finally {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)dealloc {
    self.target = nil;
    self.action = nil;
    self.tile = nil;
}

@end
