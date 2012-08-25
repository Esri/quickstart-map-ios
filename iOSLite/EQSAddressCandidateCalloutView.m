//
//  EQSAddressCandidateCalloutView.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidateCalloutView.h"

@implementation EQSAddressCandidateCalloutView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 7;
    }
    return self;
}
@end
