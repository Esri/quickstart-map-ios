//
//  EQSAddressCandidateCalloutViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <EsriQuickStart/EsriQuickStart.h>

#import "EQSSearchResultCalloutViewController.h"
#import "EQSSearchResultPanelViewController.h"

@interface EQSSearchResultCalloutViewController () 
@property (weak, nonatomic) IBOutlet EQSSearchResultPanelViewController *mainViewController;
@end

@implementation EQSSearchResultCalloutViewController
@synthesize mainViewController = _mainViewController;

+ (id) viewControllerWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType
{
    return [[EQSSearchResultCalloutViewController alloc] initWithAddressCandidate:candidate
                                                                               OfType:candidateType];
}

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType
{
    if (self)
    {
        self.candidate = candidate;
        self.resultType = candidateType;
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
    if (self.searchResultViewDelegate)
    {
        if ([self.searchResultViewDelegate respondsToSelector:@selector(searchResultViewController:DidTapViewType:)])
        {
            [self.searchResultViewDelegate searchResultViewController:self DidTapViewType:EQSSearchResultViewTypeCalloutView];
        }
    }
}
@end
