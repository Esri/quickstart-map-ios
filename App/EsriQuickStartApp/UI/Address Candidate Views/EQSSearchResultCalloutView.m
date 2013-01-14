//
//  EQSAddressCandidateCalloutView.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSSearchResultCalloutView.h"

@implementation EQSSearchResultCalloutView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 4;
    }
    return self;
}
@end
