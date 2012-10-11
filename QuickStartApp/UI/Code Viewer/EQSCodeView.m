//
//  EQSCodeView.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSCodeView.h"
#import <ArcGIS/ArcGIS.h>

@interface EQSCodeView ()
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (weak, nonatomic) IBOutlet UIView *tabBase;
@property (weak, nonatomic) IBOutlet UIButton *tabImage;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@end

@implementation EQSCodeView
@synthesize topLevelView;
@synthesize viewController;
@synthesize tabBase;
@synthesize tabImage;
@synthesize webView;
@synthesize mainContainer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EQSCodeView" owner:self options:nil];
        [self addSubview:self.topLevelView];
        self.topLevelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.topLevelView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.autoresizesSubviews = YES;
    }
    return self;
}

- (void) awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.topLevelView.backgroundColor = [UIColor clearColor];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inBase = CGRectContainsPoint(self.tabBase.frame, point);
    BOOL inMainContainer = CGRectContainsPoint(self.mainContainer.frame, point);
    return inBase || inMainContainer;
}
@end
