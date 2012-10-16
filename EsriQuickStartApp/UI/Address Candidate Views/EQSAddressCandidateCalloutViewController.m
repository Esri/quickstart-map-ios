//
//  EQSAddressCandidateCalloutViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidateCalloutViewController.h"
#import "EQSAddressCandidatePanelViewController.h"
#import "AGSPoint+GeneralUtilities.h"

@interface EQSAddressCandidateCalloutViewController () 
@property (weak, nonatomic) IBOutlet EQSAddressCandidatePanelViewController *mainViewController;
@end

@implementation EQSAddressCandidateCalloutViewController
@synthesize mainViewController = _mainViewController;

+ (id) viewControllerWithCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    return [[EQSAddressCandidateCalloutViewController alloc] initWithAddressCandidate:candidate
                                                                               OfType:candidateType];
}

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    if (self)
    {
        self.candidate = candidate;
        self.candidateType = candidateType;
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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.mainViewController ensureVisibleInParentUIScrollView];
}

- (void) setGraphic:(AGSGraphic *)graphic
{
    super.graphic = graphic;
    
    if (self.graphic)
    {
        self.graphic.infoTemplateDelegate = self;
    }
}

- (void) prepareView
{
	[super prepareView];
	
	if (self.view)
	{
		UILabel *refView = self.refLabel;

		self.primaryLabel.textColor =
        self.latLonLabel.textColor =
        self.locatorLabel.textColor =
        self.scoreLabel.textColor =
        refView.textColor;
	}
}

#pragma mark - AGSCalloutDelegate
- (UIView *) customViewForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)mapPoint
{
    return self.view;
}

- (IBAction)zoomButtonTapped:(id)sender {
    if (self.candidateViewDelegate)
    {
        if ([self.candidateViewDelegate respondsToSelector:@selector(candidateViewController:DidTapViewType:)])
        {
            [self.candidateViewDelegate candidateViewController:self DidTapViewType:EQSCandidateViewTypeCalloutView];
        }
    }
}
@end
