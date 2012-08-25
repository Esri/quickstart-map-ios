//
//  EQSAddressCandidateCalloutViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/24/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSAddressCandidateCalloutViewController.h"

@interface EQSAddressCandidateCalloutViewController ()
@property (weak, nonatomic) IBOutlet EQSAddressCandidateViewController *mainViewController;

@end

@implementation EQSAddressCandidateCalloutViewController
@synthesize mainViewController = _mainViewController;

@synthesize candidate = _candidate;
@synthesize graphic = _graphic;

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
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.mainViewController ensureMainViewVisibleInParentUIScrollView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
