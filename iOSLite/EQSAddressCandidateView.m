//
//  EQSAddressCandidateView.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidateView.h"

@interface EQSAddressCandidateView ()
//@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (nonatomic, assign) CGSize originalSize;
@end

@implementation EQSAddressCandidateView
@synthesize viewController;
//@synthesize topLevelView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        [[NSBundle mainBundle] loadNibNamed:@"EQSAddressCandidateView" owner:self options:nil];
//        self.frame = self.topLevelView.frame;
//        [self addSubview:self.topLevelView];
//        self.topLevelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.autoresizesSubviews = YES;
//        self.backgroundColor = [UIColor clearColor];
//        self.topLevelView.layer.cornerRadius = 7;
//        self.originalSize = self.frame.size;
        self.layer.cornerRadius = 7;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
//        [[NSBundle mainBundle] loadNibNamed:@"EQSAddressCandidateView" owner:self options:nil];
//        [self addSubview:self.topLevelView];
        self.layer.cornerRadius = 7;
    }
    return self;
}
@end
