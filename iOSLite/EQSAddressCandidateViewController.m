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

@dynamic nextPosition;

- (UIView *) customViewForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint
{
    EQSAddressCandidateView *acv = (EQSAddressCandidateView *)self.view;
    [acv setupForCalloutTemplate];
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
@end