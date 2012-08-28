//
//  EQSAddressCandidateViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidatePanelViewController.h"
#import "EQSAddressCandidateView.h"
#import "EQSAddressCandidateCalloutView.h"
#import "EQSAddressCandidateCalloutViewController.h"
#import "AGSPoint+GeneralUtilities.h"

#import "EQSGeoServicesNotifications.h"

#define kEQSAddressCandidateViewSpacing 10

@interface EQSAddressCandidatePanelViewController ()
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabel;
@property (strong, nonatomic) IBOutlet EQSAddressCandidateCalloutViewController *calloutViewController;
@end

@implementation EQSAddressCandidatePanelViewController
@synthesize secondaryLabel;
@synthesize calloutViewController = _calloutViewController;
@dynamic nextPosition;

#pragma mark - View and ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setSecondaryLabel:nil];
    
//    [self setCalloutViewController:nil];

    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.alpha = 0;

    [self prepareView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSTimeInterval animationDuration = 0.4;
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.alpha = 1;
    }];
}

+ (id) viewControllerWithCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    return [[EQSAddressCandidatePanelViewController alloc] initWithAddressCandidate:candidate
                                                                             OfType:candidateType];
}

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    self = [super initWithNibName:@"EQSAddressCandidateView" bundle:nil];

    if (self)
    {
        self.candidateType = candidateType;
        self.candidate = candidate;
    }
    
    return self;
}


#pragma mark - Property setters
- (void) setGraphic:(AGSGraphic *)graphic
{
    super.graphic = graphic;
    
    if (self.graphic)
    {
        // Make sure we propagate the graphic through to the calloutViewController
        self.calloutViewController.graphic = graphic;
    }
}

- (void) setCalloutViewController:(EQSAddressCandidateCalloutViewController *)calloutViewController
{
    _calloutViewController = calloutViewController;
    if (_calloutViewController)
    {
        _calloutViewController.candidate = self.candidate;
        _calloutViewController.candidateType = self.candidateType;
        _calloutViewController.graphic = self.graphic;
    }
}


- (void) prepareView
{
    [super prepareView];

    if (self.view)
    {
        UILabel *refView = self.refLabel;
        self.secondaryLabel.textColor = refView.textColor;
        self.view.backgroundColor = refView.backgroundColor;
        
        self.secondaryLabel.text = @"";
    }
}


#pragma mark - ScrollView helper functions
- (CGRect) nextPosition
{
    CGRect myFrame = self.view.frame;
    return CGRectOffset(myFrame, myFrame.size.width + kEQSAddressCandidateViewSpacing, 0);
}

- (void) addToScrollView:(UIScrollView *)parentView
{
    [self addToScrollView:parentView RelativeTo:nil];
}

- (void) addToScrollView:(UIScrollView *)parentView
              RelativeTo:(EQSAddressCandidatePanelViewController *)previousCandidate
{
    [self setPositionInScrollView:parentView RelativeTo:previousCandidate Rearranging:NO];
    
    [parentView addSubview:self.view];
    
    [self sizeParentScrollView];
}

- (void)setPositionInScrollView:(UIScrollView *)parentView
                     RelativeTo:(EQSAddressCandidatePanelViewController *)previousCandidate
                    Rearranging:(BOOL)rearranging
{
    CGRect proposedPosition = CGRectNull;
    if (previousCandidate)
    {
        proposedPosition = previousCandidate.nextPosition;
    }
    else
    {
        // Add at end.
        EQSAddressCandidatePanelViewController *rightmostCandidateVC =
            rearranging?previousCandidate:[EQSAddressCandidatePanelViewController findRightmostItemIn:(UIScrollView *)parentView];
        if (rightmostCandidateVC)
        {
            proposedPosition = rightmostCandidateVC.nextPosition;
        }
        else
        {
            CGSize mySize = self.view.frame.size;
            CGSize parentSize = parentView.frame.size;
            proposedPosition = CGRectMake(kEQSAddressCandidateViewSpacing,
                                          (parentSize.height - mySize.height)/2,
                                          mySize.width, mySize.height);
        }
    }
    
    self.view.frame = proposedPosition;
}

- (UIScrollView *) removeFromParentScrollView
{
    if ([self.view.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *exSuperView = (UIScrollView *)self.view.superview;
        [UIView animateWithDuration:0.4
                         animations:^{
                             [self.view removeFromSuperview];
                             [EQSAddressCandidatePanelViewController positionAddressCandidateViewsIn:exSuperView]; 
                         }];
        return exSuperView;
    }
    return nil;
}

+ (void) positionAddressCandidateViewsIn:(UIScrollView *)superView
{
    EQSAddressCandidatePanelViewController *previousCandidate = nil;

    for (UIView *v in superView.subviews)
    {
        if ([v isKindOfClass:[EQSAddressCandidateView class]])
        {
            EQSAddressCandidateView *acv = (EQSAddressCandidateView *)v;
            [acv.viewController setPositionInScrollView:superView RelativeTo:previousCandidate Rearranging:YES];
            previousCandidate = acv.viewController;
        }
    }
    
    [EQSAddressCandidatePanelViewController sizeScrollView:superView];
}

- (void) ensureVisibleInParentUIScrollView
{
    UIView *parentView = self.view.superview;
    if ([parentView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *parentScrollView = (UIScrollView *)parentView;
        CGSize parentSize = parentScrollView.frame.size;
        CGFloat xOffset = (parentSize.width - self.view.frame.size.width) / 2;
        CGRect newRect = CGRectInset(self.view.frame, -xOffset, 0);
//        NSLog(@"Old Rect %@ [%.2f] New Rect %@", NSStringFromCGRect(self.view.frame) , xOffset, NSStringFromCGRect(newRect));
        [parentScrollView scrollRectToVisible:newRect animated:YES];
    }
}

+ (EQSAddressCandidatePanelViewController *) findRightmostItemIn:(UIScrollView *)parentView
{
    CGFloat maxOriginX = CGFLOAT_MIN;
    EQSAddressCandidateView *rightmostView = nil;
    
    for (UIView *subView in parentView.subviews)
    {
        if ([subView isKindOfClass:[EQSAddressCandidateView class]])
        {
            EQSAddressCandidateView *v = (EQSAddressCandidateView *)subView;
            if (v.frame.origin.x + v.frame.size.width > maxOriginX)
            {
                maxOriginX = v.frame.origin.x + v.frame.size.width;
                rightmostView = v;
            }
        }
    }
    
    return rightmostView.viewController;
}

+ (void)sizeScrollView:(UIScrollView *)containingScrollView
{
    CGRect totalRect = CGRectZero;
    for (UIView *v in containingScrollView.subviews)
    {
        if ([v isKindOfClass:[EQSAddressCandidateView class]])
        {
            totalRect = CGRectUnion(totalRect, v.frame);
        }
    }
    if (!CGRectEqualToRect(totalRect, CGRectZero))
    {
        // Add spacing to left and right of the AddressCandidateViews
        totalRect = CGRectMake(totalRect.origin.x, totalRect.origin.y,
                               totalRect.size.width + kEQSAddressCandidateViewSpacing, totalRect.size.height);
    }
    else
    {
        totalRect = containingScrollView.frame;
    }
    
    containingScrollView.contentSize = totalRect.size;
}

- (void) sizeParentScrollView
{
    if ([self.view.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *containingScrollView = (UIScrollView *)self.view.superview;
        [EQSAddressCandidatePanelViewController sizeScrollView:containingScrollView];
    }
}

- (IBAction)zoomButtonTapped:(id)sender {
    if (self.candidateViewDelegate)
    {
        if ([self.candidateViewDelegate respondsToSelector:@selector(candidateViewController:DidTapViewType:)])
        {
            [self.candidateViewDelegate candidateViewController:self DidTapViewType:EQSCandidateViewTypePanelView];
        }
    }
}
@end