//
//  EQSAddressCandidateViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <EsriQuickStart/EsriQuickStart.h>

#import "EQSSearchResultPanelViewController.h"
#import "EQSSearchResultView.h"
#import "EQSSearchResultCalloutView.h"
#import "EQSSearchResultCalloutViewController.h"

#define kEQSAddressCandidateViewSpacing 10

@interface EQSSearchResultPanelViewController ()
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabel;
@property (strong, nonatomic) IBOutlet EQSSearchResultCalloutViewController *calloutViewController;
@end

@implementation EQSSearchResultPanelViewController
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

+ (id) viewControllerWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType
{
    return [[EQSSearchResultPanelViewController alloc] initWithAddressCandidate:candidate
                                                                         OfType:candidateType];
}

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType
{
    self = [super initWithNibName:@"EQSSearchResultView" bundle:nil];

    if (self)
    {
        self.resultType = candidateType;
        self.candidate = candidate;
    }
    
    return self;
}

+(id)viewControllerWithFindResult:(AGSLocatorFindResult *)result OfType:(EQSSearchResultType)resultType;
{
    return [[EQSSearchResultPanelViewController alloc] initWithFindResult:result
                                                                   OfType:resultType];
}

-(id)initWithFindResult:(AGSLocatorFindResult *)result OfType:(EQSSearchResultType)resultType;
{
    self = [super initWithNibName:@"EQSSearchResultView" bundle:nil];
    
    if (self)
    {
        self.resultType = resultType;
        self.findResult = result;
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

- (void) setCalloutViewController:(EQSSearchResultCalloutViewController *)calloutViewController
{
    _calloutViewController = calloutViewController;
    if (_calloutViewController)
    {
        _calloutViewController.candidate = self.candidate;
        _calloutViewController.findResult = self.findResult;
        _calloutViewController.resultType = self.resultType;
        _calloutViewController.graphic = self.graphic;
    }
}


- (void) prepareView
{
    [super prepareView];

    if (self.view)
    {
        UILabel *refView = self.refLabel;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            self.primaryLabel.textColor = refView.textColor;
            self.secondaryLabel.textColor = refView.textColor;
            self.latLonLabel.textColor = refView.textColor;
            self.scoreLabel.textColor = refView.textColor;
            self.locatorLabel.textColor = refView.textColor;
            
//            self.view.backgroundColor = refView.backgroundColor;
        }
        
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
              RelativeTo:(EQSSearchResultPanelViewController *)previousCandidate
{
    [self setPositionInScrollView:parentView RelativeTo:previousCandidate Rearranging:NO];
    
    [parentView addSubview:self.view];
    
    [self sizeParentScrollView];
}

- (void)setPositionInScrollView:(UIScrollView *)parentView
                     RelativeTo:(EQSSearchResultPanelViewController *)previousCandidate
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
        EQSSearchResultPanelViewController *rightmostCandidateVC =
            rearranging?previousCandidate:[EQSSearchResultPanelViewController findRightmostItemIn:(UIScrollView *)parentView];
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
                             [EQSSearchResultPanelViewController positionAddressCandidateViewsIn:exSuperView]; 
                         }];
        return exSuperView;
    }
    return nil;
}

+ (void) positionAddressCandidateViewsIn:(UIScrollView *)superView
{
    EQSSearchResultPanelViewController *previousCandidate = nil;

    for (UIView *v in superView.subviews)
    {
        if ([v isKindOfClass:[EQSSearchResultView class]])
        {
            EQSSearchResultView *acv = (EQSSearchResultView *)v;
            [acv.viewController setPositionInScrollView:superView RelativeTo:previousCandidate Rearranging:YES];
            previousCandidate = acv.viewController;
        }
    }
    
    [EQSSearchResultPanelViewController sizeScrollView:superView];
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

+ (EQSSearchResultPanelViewController *) findRightmostItemIn:(UIScrollView *)parentView
{
    CGFloat maxOriginX = CGFLOAT_MIN;
    EQSSearchResultView *rightmostView = nil;
    
    for (UIView *subView in parentView.subviews)
    {
        if ([subView isKindOfClass:[EQSSearchResultView class]])
        {
            EQSSearchResultView *v = (EQSSearchResultView *)subView;
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
        if ([v isKindOfClass:[EQSSearchResultView class]])
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
        [EQSSearchResultPanelViewController sizeScrollView:containingScrollView];
    }
}

- (IBAction)zoomButtonTapped:(id)sender {
    if (self.searchResultViewDelegate)
    {
        if ([self.searchResultViewDelegate respondsToSelector:@selector(searchResultViewController:DidTapViewType:)])
        {
            [self.searchResultViewDelegate searchResultViewController:self DidTapViewType:EQSSearchResultViewTypePanelView];
        }
    }
}
@end