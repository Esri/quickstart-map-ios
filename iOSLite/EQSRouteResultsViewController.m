//
//  EQSRouteResultsViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsViewController.h"
#import "EQSRouteResultsTableViewController.h"

@interface EQSRouteResultsViewController () <EQSRouteDisplayTableViewDelegate>
@property (strong, nonatomic) IBOutlet EQSRouteResultsTableViewController *tableViewController;
@property (strong, nonatomic) IBOutlet UILabel *routeResultsDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *routeResultsTimeLabel;
@end

@implementation EQSRouteResultsViewController
@synthesize tableViewController;
@synthesize routeResultsDistanceLabel;
@synthesize routeResultsTimeLabel;

@synthesize mapView = _mapView;
@synthesize routeResult = _routeResult;
@synthesize hidden = _hidden;
@synthesize routeDisplayDelegate = _routeDisplayDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _hidden = YES;
    [self setHiddenInternal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setRouteResult:(AGSRouteResult *)routeResult
{
    _routeResult = routeResult;
    
    if (_routeResult)
    {
        self.routeResultsDistanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f", routeResult.directions.totalLength];
        self.routeResultsTimeLabel.text = [NSString stringWithFormat:@"Time: %.2f minute%@", routeResult.directions.totalDriveTime,
                                           routeResult.directions.totalDriveTime == 1.0f?@"":@"s"];
        
        self.tableViewController.routeResult = routeResult;
        self.tableViewController.directionsDelegate = self;
    }
    
    self.hidden = (_routeResult == nil);
}

- (void) setHidden:(BOOL)hidden
{
    BOOL newHidden = NO;
    
    if (self.routeResult == nil)
    {
        newHidden = YES;
    }
    else
    {
        newHidden = hidden;
    }
    
    if (newHidden != _hidden)
    {
        _hidden = newHidden;
        [self setHiddenInternal];
    }
}

- (void) setHiddenInternal
{
    double animationDuration = 0.4;
    if (!_hidden)
    {
        self.view.alpha = 0;
        self.view.hidden = NO;
        [UIView animateWithDuration:animationDuration animations:^{
            self.view.alpha = 1;
        }];
    }
    else
    {
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.view.alpha = 0;
                         } completion:^(BOOL finished) {
                             self.view.hidden = YES;
                         }];
    }
}

- (void) direction:(AGSDirectionGraphic *)direction selectedFromRouteResult:(AGSRouteResult *)routeResult
{
    if (self.routeDisplayDelegate)
    {
        if ([self.routeDisplayDelegate respondsToSelector:@selector(direction:selectedFromRouteResult:)])
        {
            [self.routeDisplayDelegate direction:direction selectedFromRouteResult:routeResult];
        }
    }
}


@end
