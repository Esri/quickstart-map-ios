//
//  EQSAddressCandidateViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidateViewController.h"
#import "EQSAddressCandidateView.h"
#import "AGSPoint+GeneralUtilities.h"

#define kEQSAddressCandidateViewSpacing 10

@interface EQSAddressCandidateView (Internal)
- (void) setupForCalloutTemplate;
@end

@interface EQSAddressCandidateViewController ()

@property (weak, nonatomic) IBOutlet UIView *topLevelView;
@property (nonatomic, readonly) CGRect nextPosition;

@property (weak, nonatomic) IBOutlet UILabel *addressPrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressSecondaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateLatLonLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateLocatorLabel;

- (IBAction)zoomButtonTapped:(id)sender;

@property (nonatomic, assign) BOOL isAGSCalloutView;
@end

@implementation EQSAddressCandidateViewController
@synthesize candidateScoreLabel;
@synthesize candidateLocatorLabel;
@synthesize topLevelView;
@synthesize addressCandidateView;

@synthesize addressPrimaryLabel;
@synthesize addressSecondaryLabel;
@synthesize candidateLatLonLabel;

@synthesize candidate = _candidate;

@synthesize candidateViewDelegate = _candidateViewDelegate;
@synthesize isAGSCalloutView = _isAGSCalloutView;

@dynamic nextPosition;

- (UIView *) customViewForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint
{
    EQSAddressCandidateView *acv = (EQSAddressCandidateView *)self.view;
    [acv setupForCalloutTemplate];
    self.isAGSCalloutView = YES;
    return self.view;
}

- (CGRect) nextPosition
{
    CGRect myFrame = self.view.frame;
    return CGRectOffset(myFrame, myFrame.size.width + kEQSAddressCandidateViewSpacing, 0);
}

- (void) addToParentView:(UIView *)parentView relativeTo:(EQSAddressCandidateView *)previousView
{
    CGRect proposedPosition = CGRectNull;
    if (previousView)
    {
        proposedPosition = previousView.viewController.nextPosition;
    }
    else
    {
        CGSize mySize = self.view.frame.size;
        CGSize parentSize = parentView.frame.size;
        proposedPosition = CGRectMake(kEQSAddressCandidateViewSpacing,
                                      (parentSize.height - mySize.height)/2,
                                      mySize.width, mySize.height);
    }

    [parentView addSubview:self.view];
    self.view.frame = proposedPosition;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.view.alpha = 0;
}

- (void) viewDidAppear:(BOOL)animated
{
    NSTimeInterval animationDuration = self.isAGSCalloutView?0:0.4;
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.alpha = 1;
    }];
}

+ (void) setContentWidthOfScrollViewContainingCandidateViews:(UIScrollView *)containingScrollView UsingTemplate:(EQSAddressCandidateView *)templateView
{
    CGFloat newWidth = containingScrollView.frame.size.width;
    if (templateView)
    {
        NSUInteger items = containingScrollView.subviews.count;
        newWidth = [EQSAddressCandidateViewController getWidthOfNumber:items OfAddressCandidateViews:templateView];
    }
    containingScrollView.contentSize = CGSizeMake(newWidth, containingScrollView.frame.size.height);
}

+ (CGFloat) getWidthOfNumber:(NSUInteger)numberOfViews OfAddressCandidateViews:(EQSAddressCandidateView *)templateView
{
    return numberOfViews==0?0:kEQSAddressCandidateViewSpacing + (numberOfViews * (templateView.frame.size.width + kEQSAddressCandidateViewSpacing));
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isAGSCalloutView = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.candidate = nil;
}

- (void)setCandidate:(AGSAddressCandidate *)candidate
{
    _candidate = candidate;
    if (candidate)
    {
        self.addressPrimaryLabel.text = self.candidate.addressString;
        self.addressSecondaryLabel.text = @"";
        self.candidateLatLonLabel.text = [NSString stringWithFormat:@"%4.4f,%4.4f",
                                          _candidate.location.latitude,
                                          _candidate.location.longitude];
        self.candidateScoreLabel.text = [NSString stringWithFormat:@"Score: %.2f", _candidate.score];
        NSString *locatorName = [_candidate.attributes objectForKey:@"Addr_Type"];
        self.candidateLocatorLabel.text = locatorName;
    }
    else
    {
        self.addressPrimaryLabel.text = @"";
        self.addressSecondaryLabel.text = @"";
        self.candidateLatLonLabel.text = @"";
        self.candidateScoreLabel.text = @"";
    }
}

- (IBAction)zoomButtonTapped:(id)sender {
    if (self.candidateViewDelegate)
    {
        if ([self.candidateViewDelegate respondsToSelector:@selector(candidateView:DidTapZoomToCandidate:)])
        {
            [self.candidateViewDelegate candidateView:(EQSAddressCandidateView *)self.view
                                DidTapZoomToCandidate:self.candidate];
        }
    }
}
@end