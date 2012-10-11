//
//  EQSBorderedButton.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 9/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSBorderedButton.h"

#import <QuartzCore/QuartzCore.h>

@interface EQSBorderedButton ()
@property (nonatomic, retain) UIColor *stashedBackgroundColor;
@end

@implementation EQSBorderedButton

@synthesize stashedBackgroundColor = _stashedBackgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10.0f;
        self.layer.borderColor = [self titleColorForState:UIControlStateNormal].CGColor;
        self.layer.borderWidth = 1;
        self.stashedBackgroundColor = self.backgroundColor;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
        self.layer.cornerRadius = 10.0f;
        self.layer.borderColor = [self titleColorForState:UIControlStateNormal].CGColor;
        self.layer.borderWidth = 1.5f;
        self.stashedBackgroundColor = self.backgroundColor;
    }
    return self;
}

- (void) setSelected:(BOOL)selected
{
    super.selected = selected;
    if (selected)
    {
        UIColor *col = [self titleColorForState:UIControlStateSelected];
        NSLog(@"%@", col);
        self.backgroundColor = [self titleColorForState:UIControlStateSelected];
    }
    else
    {
        self.backgroundColor = self.stashedBackgroundColor;
    }
}
@end
