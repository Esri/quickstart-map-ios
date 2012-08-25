//
//  EQSAddressCandidateViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidateViewController.h"
#import "EQSAddressCandidateView.h"
#import "EQSAddressCandidateCalloutView.h"
#import "EQSAddressCandidateCalloutViewController.h"
#import "AGSPoint+GeneralUtilities.h"

#import "EQSGeoServicesNotifications.h"

#define kEQSAddressCandidateViewSpacing 10

@interface EQSAddressCandidateView (Internal)
- (void) setupForCalloutTemplate;
@end

@interface EQSAddressCandidateViewController ()
@property (nonatomic, readonly) CGRect nextPosition;

@property (weak, nonatomic) IBOutlet UILabel *candidatePrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateSecondaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateLatLonLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateLocatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *candidateScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *calloutPrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *calloutLatLonLabel;
@property (weak, nonatomic) IBOutlet UILabel *calloutLocatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *calloutScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *revColRefView;
@property (weak, nonatomic) IBOutlet UILabel *fwdColRefView;
@property (weak, nonatomic) IBOutlet UILabel *geolocColRefView;
@property (weak, nonatomic) IBOutlet UILabel *routeStartColRefView;
@property (weak, nonatomic) IBOutlet UILabel *routeEndColRefView;

- (IBAction)zoomButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet EQSAddressCandidateCalloutView *calloutView;
@property (strong, nonatomic) IBOutlet EQSAddressCandidateCalloutViewController *calloutViewController;

@property (weak, nonatomic) IBOutlet UIButton *candidateViewButton;
@property (weak, nonatomic) IBOutlet UIButton *calloutViewButton;

@end

@implementation EQSAddressCandidateViewController
@synthesize calloutView;
@synthesize calloutViewController;
@synthesize candidateViewButton;
@synthesize calloutViewButton;
@synthesize candidatePrimaryLabel;
@synthesize candidateSecondaryLabel;
@synthesize candidateLatLonLabel;
@synthesize candidateLocatorLabel;
@synthesize candidateScoreLabel;

@synthesize calloutPrimaryLabel;
@synthesize calloutLatLonLabel;
@synthesize calloutLocatorLabel;
@synthesize calloutScoreLabel;

@synthesize candidate = _candidate;

@synthesize candidateViewDelegate = _candidateViewDelegate;
@synthesize revColRefView;
@synthesize fwdColRefView;
@synthesize geolocColRefView;
@synthesize routeStartColRefView;
@synthesize routeEndColRefView;

@synthesize candidateType = _candidateType;

@dynamic nextPosition;

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    self = [super initWithNibName:@"EQSAddressCandidateView" bundle:nil];
    
    if (self)
    {
        self.candidate = candidate;
        self.candidateType = candidateType;
    }
    return self;
}

- (UIView *) customViewForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint
{
    return self.calloutView;
}

- (void) setCandidateType:(EQSCandidateType)candidateType
{
    _candidateType = candidateType;
    if (self.view)
    {
        [self updateCandidateDisplay];
    }
}

- (void)setCandidate:(AGSAddressCandidate *)candidate
{
    _candidate = candidate;
    [self updateCandidateDisplay];
}

- (void) updateCandidateDisplay
{
    UILabel *refView = nil;
    switch (self.candidateType) {
        case EQSCandidateTypeForwardGeocode:
            refView = self.fwdColRefView;
            self.candidateLocatorLabel.hidden = NO;
            break;
        case EQSCandidateTypeReverseGeocode:
            refView = self.revColRefView;
            self.candidateLocatorLabel.hidden = YES;
            break;
        case EQSCandidateTypeGeolocation:
            refView = self.geolocColRefView;
            self.candidateLocatorLabel.hidden = YES;
            break;
        case EQSCandidateTypeDirectionsStart:
            refView = self.routeStartColRefView;
            self.candidateLocatorLabel.hidden = YES;
            break;
        case EQSCandidateTypeDirectionsEnd:
            refView = self.routeEndColRefView;
            self.candidateLocatorLabel.hidden = NO;
            break;
        default:
            NSLog(@"Unexpected EQSCandidateType: %d", self.candidateType);
            break;
    }
    
    self.candidatePrimaryLabel.textColor =
    self.candidateSecondaryLabel.textColor =
    self.candidateLatLonLabel.textColor =
    self.candidateLocatorLabel.textColor =
    self.candidateScoreLabel.textColor =
    self.calloutPrimaryLabel.textColor =
    self.calloutLatLonLabel.textColor =
    self.calloutLocatorLabel.textColor =
    self.calloutScoreLabel.textColor =
    refView.textColor;
    
    self.view.backgroundColor = self.calloutView.backgroundColor = refView.backgroundColor;
    
    if (self.candidate)
    {
        NSString *latLonString = [NSString stringWithFormat:@"%4.4f,%4.4f",
                                  self.candidate.location.latitude,
                                  self.candidate.location.longitude];
        NSString *scoreString = [NSString stringWithFormat:@"Score: %.2f", self.candidate.score];
        
        switch (self.candidateType)
        {
            case EQSCandidateTypeForwardGeocode:
            {
                NSString *locatorName = [self.candidate.attributes objectForKey:@"Addr_Type"];

                self.candidatePrimaryLabel.text =self.candidate.addressString;
                self.candidateSecondaryLabel.text = @"";
                self.candidateLatLonLabel.text = latLonString;
                self.candidateLocatorLabel.text = locatorName;
                self.candidateScoreLabel.text = scoreString;
                
                self.calloutPrimaryLabel.text = self.candidatePrimaryLabel.text;
                self.calloutLatLonLabel.text = self.candidateLatLonLabel.text;
                self.calloutLocatorLabel.text = self.candidateLocatorLabel.text;
                self.calloutScoreLabel.text = self.candidateScoreLabel.text;
            }
                break;
                
            case EQSCandidateTypeReverseGeocode:
            case EQSCandidateTypeGeolocation:
            case EQSCandidateTypeDirectionsStart:
            case EQSCandidateTypeDirectionsEnd:
            {
                NSDictionary *addData = self.candidate.address;
                NSString *addStr = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                    [addData objectForKey:kEQSAddressCandidateAddressField],
                                    [addData objectForKey:kEQSAddressCandidateCityField],
                                    [addData objectForKey:kEQSAddressCandidateStateField],
                                    [addData objectForKey:kEQSAddressCandidateZipField]];
                NSString *locatorName = [self.candidate.address objectForKey:@"Loc_name"];

                self.candidatePrimaryLabel.text =addStr;
                self.candidateSecondaryLabel.text = @"";
                self.candidateLatLonLabel.text = latLonString;
                self.candidateLocatorLabel.text = @"";
                self.candidateScoreLabel.text = locatorName;
                
                self.calloutPrimaryLabel.text = self.candidatePrimaryLabel.text;
                self.calloutLatLonLabel.text = self.candidateLatLonLabel.text;
                self.calloutLocatorLabel.text = self.candidateLocatorLabel.text;
                self.calloutScoreLabel.text = self.candidateScoreLabel.text;
            }
                break;
                
            default:
                NSLog(@"Unknown Candidate View Type");
                break;
        }
    }
    else
    {
        self.candidatePrimaryLabel.text = @"";
        self.candidateSecondaryLabel.text = @"";
        self.candidateLatLonLabel.text = @"";
        self.candidateScoreLabel.text = @"";
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setCandidatePrimaryLabel:nil];
    [self setCandidateSecondaryLabel:nil];
    [self setCandidateLatLonLabel:nil];
    [self setCandidateLocatorLabel:nil];
    [self setCandidateScoreLabel:nil];
    
    [self setCalloutPrimaryLabel:nil];
    [self setCalloutLatLonLabel:nil];
    [self setCalloutLocatorLabel:nil];
    [self setCalloutScoreLabel:nil];
    
    [self setCalloutView:nil];
    
    [self setCandidate:nil];
    [self setGraphic:nil];
    
    [self setCalloutViewController:nil];
    [self setCandidateViewButton:nil];
    [self setCalloutViewButton:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.view.alpha = 0;
    [self updateCandidateDisplay];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSTimeInterval animationDuration = 0.4;
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.alpha = 1;
    }];
}

- (void) setGraphic:(AGSGraphic *)graphic
{
    _graphic = graphic;
    if (graphic.infoTemplateDelegate == nil)
    {
        graphic.infoTemplateDelegate = self;
    }
}




- (CGRect) nextPosition
{
    CGRect myFrame = self.view.frame;
    return CGRectOffset(myFrame, myFrame.size.width + kEQSAddressCandidateViewSpacing, 0);
}

- (void) addToParentView:(UIView *)parentView relativeTo:(EQSAddressCandidateViewController *)previousCandidate
{
    CGRect proposedPosition = CGRectNull;
    if (previousCandidate)
    {
        proposedPosition = previousCandidate.nextPosition;
    }
    else
    {
        // Add at end.
        EQSAddressCandidateViewController *rightmostCandidateVC =
        [EQSAddressCandidateViewController findRightmostItemIn:(UIScrollView *)parentView];
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
    
    [parentView addSubview:self.view];
    if ([parentView isKindOfClass:[UIScrollView class]])
    {
        [EQSAddressCandidateViewController setContentWidthOfScrollViewContainingCandidateViews:(UIScrollView *)parentView
                                                                                 UsingTemplate:(EQSAddressCandidateView *)self.view];
    }
    self.view.frame = proposedPosition;
}

- (void) ensureMainViewVisibleInParentUIScrollView
{
    UIView *parentView = self.view.superview;
    if ([parentView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *parentScrollView = (UIScrollView *)parentView;
        CGSize parentSize = parentScrollView.frame.size;
        CGFloat xOffset = (parentSize.width - self.view.frame.size.width) / 2;
        CGRect newRect = CGRectInset(self.view.frame, -xOffset, 0);
        NSLog(@"Old Rect %@ [%.2f] New Rect %@", NSStringFromCGRect(self.view.frame) , xOffset, NSStringFromCGRect(newRect));
        [parentScrollView scrollRectToVisible:newRect animated:YES];
    }
}

+ (EQSAddressCandidateViewController *) findRightmostItemIn:(UIScrollView *)parentView
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

+ (void) setContentWidthOfScrollViewContainingCandidateViews:(UIScrollView *)containingScrollView
                                               UsingTemplate:(EQSAddressCandidateView *)templateView
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

- (IBAction)zoomButtonTapped:(id)sender {
    if (self.candidateViewDelegate)
    {
        if ([self.candidateViewDelegate respondsToSelector:@selector(candidateViewController:DidTapViewType:)])
        {
            EQSCandidateViewType viewType;
            if (sender == self.calloutViewButton)
            {
                viewType = EQSCandidateViewTypeView;
            }
            else if (sender == self.candidateViewButton)
            {
                viewType = EQSCandidateViewTypeCalloutView;
            }
            else
            {
                NSLog(@"Unknown sender for CandidateView zoomButtonTapped!");
                return;
            }

            [self.candidateViewDelegate candidateViewController:self DidTapViewType:viewType];
        }
    }
}
@end