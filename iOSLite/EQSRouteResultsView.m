//
//  EQSRouteResultsView.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsView.h"

@interface EQSRouteResultsView ()
@property (strong, nonatomic) IBOutlet EQSRouteResultsViewController *myVC;
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@end

@implementation EQSRouteResultsView
@synthesize myVC;
@synthesize topLevelView;
@synthesize viewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"EQSRouteResultsView" owner:self options:nil];
        [self addSubview:self.topLevelView];
        self.topLevelView.layer.cornerRadius = 7;
//        self.layer.cornerRadius = 5;
        self.topLevelView.backgroundColor = self.backgroundColor;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0];
    }
    return self;
}

- (void) awakeFromNib
{
    NSLog(@"%@", self.viewController);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
