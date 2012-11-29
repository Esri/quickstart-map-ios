//
//  EQSRouteResultsViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsViewController.h"
#import "EQSRouteResultsTableViewController.h"
#import "EQSHelper.h"

@interface UITableView (EQSRouteResults)
- (void) selectRowCallingDelegateAtIndexPath:(NSIndexPath *)indexPath
                                    animated:(BOOL)animated
                              scrollPosition:(UITableViewScrollPosition)scrollPosition;
@end

@implementation UITableView (EQSRouteResults)
- (void) selectRowCallingDelegateAtIndexPath:(NSIndexPath *)indexPath
                                    animated:(BOOL)animated
                              scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    // Why isn't this part of UITableView? I suppose it ended up with too many circular references?
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
    {
        [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
    }
    
    [self selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];

    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}
@end

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

- (IBAction)selectPreviousDirection:(id)sender
{
    NSIndexPath *currentIP = [self.tableViewController.tableView indexPathForSelectedRow];
    NSIndexPath *newSelectIP = nil;
    if (currentIP)
    {
        NSUInteger currentRow = currentIP.row;
        if (currentRow > 0)
        {
            newSelectIP = [NSIndexPath indexPathForRow:currentIP.row-1 inSection:currentIP.section];
        }
        else
        {
            newSelectIP = currentIP;
        }
    }
    else
    {
        NSUInteger numRows = [self.tableViewController.tableView numberOfRowsInSection:0];
        newSelectIP = [NSIndexPath indexPathForRow:numRows-1
                                         inSection:0];
    }

    [self.tableViewController.tableView selectRowCallingDelegateAtIndexPath:newSelectIP
                                                    animated:YES
                                              scrollPosition:UITableViewScrollPositionMiddle];
}

- (IBAction)selectNextDirection:(id)sender {
    NSIndexPath *currentIP = [self.tableViewController.tableView indexPathForSelectedRow];
    NSIndexPath *newSelectIP = nil;
    if (currentIP)
    {
        NSUInteger currentRow = currentIP.row;
        if (currentRow < [self.tableViewController.tableView numberOfRowsInSection:0]-1)
        {
            newSelectIP = [NSIndexPath indexPathForRow:currentIP.row+1 inSection:currentIP.section];
        }
        else
        {
            newSelectIP = currentIP;
        }
    }
    else
    {
        newSelectIP = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self.tableViewController.tableView selectRowCallingDelegateAtIndexPath:newSelectIP
                                                                   animated:YES
                                                             scrollPosition:UITableViewScrollPositionMiddle];
}

- (IBAction)zoomToRoute:(id)sender
{
    if (self.routeDisplayDelegate)
    {
        if ([self.routeDisplayDelegate respondsToSelector:@selector(zoomToRouteResult)])
        {
            [self.routeDisplayDelegate zoomToRouteResult];
        }
    }
}

- (IBAction)clearRoute:(id)sender
{
    if (self.routeDisplayDelegate)
    {
        if ([self.routeDisplayDelegate respondsToSelector:@selector(clearRouteResult)])
        {
            [self.routeDisplayDelegate clearRouteResult];
        }
    }
}

- (IBAction)editRoute:(id)sender {
    if (self.routeDisplayDelegate)
    {
        if ([self.routeDisplayDelegate respondsToSelector:@selector(editRoute)])
        {
            [self.routeDisplayDelegate editRoute];
        }
    }
}

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
//    _hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    _hidden = self.routeResult == nil;
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
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"ROTATED!");
}

- (void) setRouteResult:(AGSRouteResult *)routeResult
{
    _routeResult = routeResult;
    
    if (_routeResult)
    {
        self.routeResultsDistanceLabel.text = [NSString stringWithFormat:@"Distance: %@",
                                               NSStringFromAGSDirectionSetDistance(_routeResult.directions)];
        self.routeResultsTimeLabel.text = [NSString stringWithFormat:@"Time: %@",
                                           NSStringFromAGSDirectionSetTime(_routeResult.directions)];
    }
    else
    {
        self.routeResultsDistanceLabel.text = @"";
        self.routeResultsTimeLabel.text = @"";
    }

    if (self.tableViewController)
    {
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
    NSLog(@"New Hidden Value: %@", _hidden?@"HIDDEN":@"SHOWN");
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
