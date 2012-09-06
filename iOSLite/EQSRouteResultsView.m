//
//  EQSRouteResultsView.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsView.h"

@interface EQSRouteResultsView ()
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@end

@implementation EQSRouteResultsView
@synthesize topLevelView;
@synthesize tableView;
@synthesize headerView;
@synthesize footerView;
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

        UIColor *bgCol = self.backgroundColor;
        CGFloat r,g,b,a;
        [bgCol getRed:&r green:&g blue:&b alpha:&a];
        self.backgroundColor = [UIColor clearColor];
        self.topLevelView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = bgCol;
        self.headerView.backgroundColor = [self.headerView.backgroundColor colorWithAlphaComponent:a];
        self.footerView.backgroundColor = [self.footerView.backgroundColor colorWithAlphaComponent:a];

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            self.topLevelView.layer.cornerRadius = 7;
            self.layer.cornerRadius = 7;
            self.layer.masksToBounds = YES;
        }
    }
    return self;
}
@end
