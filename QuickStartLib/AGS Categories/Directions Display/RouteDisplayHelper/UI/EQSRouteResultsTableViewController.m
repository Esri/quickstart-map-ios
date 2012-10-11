//
//  EQSRouteResultsTableViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsTableViewController.h"
#import "EQSRouteResultsCell.h"
#import <ArcGIS/ArcGIS.h>

@interface AGSDirectionSet (GeneralUtilities)
- (NSUInteger) count;
@end

@implementation AGSDirectionSet (GeneralUtilities)
- (NSUInteger) count
{
    return self.graphics.count;
}
@end

@interface EQSRouteResultsTableViewController ()
@property (nonatomic, retain) EQSRouteResultsCell *templateCell;
@end

@implementation EQSRouteResultsTableViewController
@synthesize routeResult = _routeResult;

@synthesize templateCell = _templateCell;
@synthesize directionsDelegate = _directionsDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load a template cell. We'll use this when calculating cell heights. Why? See below...
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EQSRouteResultsCell" owner:self options:nil];
    self.templateCell = (EQSRouteResultsCell *)[nib objectAtIndex:0];
    
    // Make sure the template cell is the right width for when it comes to calculating each row height.
    CGRect newRect = self.templateCell.frame;
    newRect.size = CGSizeMake(self.tableView.frame.size.width, self.templateCell.frame.size.height);
    self.templateCell.frame = newRect;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view data source

- (void) setRouteResult:(AGSRouteResult *)routeResult
{
    _routeResult = routeResult;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.routeResult != nil?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.routeResult != nil?self.routeResult.directions.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EQSRouteResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        // So the TableView didn't have a spare cell handy for us to reuse. Let's create one.
        // We've defined the cell in its own NIB. Since it's the only thing in there, we know
        // how to access it. Yes, this is sanctioned code by Apple.
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EQSRouteResultsCell" owner:self options:nil];
        cell = (EQSRouteResultsCell *)[nib objectAtIndex:0];
    }

    // Now we want to populate the details of the cell using our AGSDirectionGraphic.
    // Unfortunately, it doesn't store its index in the set of directions. So...
    NSUInteger dataIndex = [indexPath indexAtPosition:indexPath.length-1];
    cell.directionIndex = dataIndex;
    cell.directionGraphic = [self graphicForIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView scrollToRowAtIndexPath:indexPath
                     atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    if (self.directionsDelegate)
    {
        if ([self.directionsDelegate respondsToSelector:@selector(direction:selectedFromRouteResult:)])
        {
            AGSDirectionGraphic *dirG = [self graphicForIndexPath:indexPath];
            if (dirG)
            {
                [self.directionsDelegate direction:dirG selectedFromRouteResult:self.routeResult];
            }
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Why not just get the cell for this indexPath? Well, it seems that doing that calls back
    // into this function, so we end up recursing infinitely and bombing out. I'm sure it makes
    // sense somewhere deep down in Apple's logic.
    AGSDirectionGraphic *g = [self graphicForIndexPath:indexPath];
    self.templateCell.directionGraphic = g;
    return [self.templateCell getHeight];
}

#pragma mark - General Table View<>AGSDirectionGraphic stuff...

- (AGSDirectionGraphic *)graphicForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger dataIndex = [indexPath indexAtPosition:indexPath.length-1];
    return [self.routeResult.directions.graphics objectAtIndex:dataIndex];
}
@end
