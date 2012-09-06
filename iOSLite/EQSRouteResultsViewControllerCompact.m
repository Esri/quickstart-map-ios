//
//  EQSRouteResultsViewControllerCompact.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 9/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsViewControllerCompact.h"
#import "EQSHelper.h"

@interface EQSRouteResultsViewController ()
- (void) direction:(AGSDirectionGraphic *)direction selectedFromRouteResult:(AGSRouteResult *)routeResult;
@end

@interface EQSRouteResultsViewControllerCompact ()
@property (nonatomic, assign) NSInteger selectedDirectionIndex;
@property (weak, nonatomic) IBOutlet UILabel *stepNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepMetricsLabel;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *stepBackwardsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stepForwardsButton;
@end

@implementation EQSRouteResultsViewControllerCompact
@synthesize selectedDirectionIndex = _selectedDirectionIndex;
@synthesize stepNumberLabel = _directionStepLabel;
@synthesize stepDetailsLabel = _directionDetailsLabel;
@synthesize stepMetricsLabel = _directionMetricsLabel;
@synthesize stepBackwardsButton = _stepBackwardsButton;
@synthesize stepForwardsButton = _stepForwardsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selectedDirectionIndex = -1;
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

- (void)setRouteResult:(AGSRouteResult *)routeResult
{
    self.selectedDirectionIndex = -1;
    [super setRouteResult:routeResult];
    if (self.routeResult)
    {
        self.selectedDirectionIndex = 0;
    }
}

- (IBAction)selectPreviousDirection:(id)sender
{
    if (self.routeResult)
    {
        NSInteger newIndex = self.selectedDirectionIndex - 1;
        if (newIndex < 0)
        {
            newIndex = 0;
        }
        self.selectedDirectionIndex = newIndex;
    }
}

- (IBAction)selectNextDirection:(id)sender {
    if (self.routeResult)
    {
        NSUInteger directionCount = self.routeResult.directions.graphics.count;
        NSInteger newIndex = self.selectedDirectionIndex + 1;
        if (newIndex > directionCount - 1)
        {
            newIndex = directionCount - 1;
        }
        self.selectedDirectionIndex = newIndex;
    }
}

- (void)setSelectedDirectionIndex:(NSInteger)selectedDirectionIndex 
{
    _selectedDirectionIndex = selectedDirectionIndex;
    if (_selectedDirectionIndex >= 0)
    {
        if (self.routeResult)
        {
            AGSDirectionSet *directions = self.routeResult.directions;
            AGSDirectionGraphic *directionGraphic = [directions.graphics objectAtIndex:_selectedDirectionIndex];
            if (directionGraphic)
            {
                [self direction:directionGraphic selectedFromRouteResult:self.routeResult];
                
                self.stepNumberLabel.text = [NSString stringWithFormat:@"%d.", selectedDirectionIndex + 1];
                self.stepDetailsLabel.text = directionGraphic.text;
                CGPoint origin = self.stepDetailsLabel.frame.origin;
                self.stepDetailsLabel.frame = CGRectMake(origin.x, origin.y, self.stepDetailsLabel.frame.size.width, [self getDetailsLabelHeight]);
                
                if (_selectedDirectionIndex != 0 &&
                    _selectedDirectionIndex != directions.graphics.count - 1)
                {
                    self.stepMetricsLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                                  NSStringFromAGSDirectionGraphicDistance(directionGraphic),
                                                  NSStringFromAGSDirectionGraphicTime(directionGraphic)];
                }
                else
                {
                    // Don't label the distance and duration for the start or end points.
                    self.stepMetricsLabel.text = @"";
                }
            }
            else
            {
                self.stepNumberLabel.text = self.stepDetailsLabel.text = self.stepMetricsLabel.text = @"";
            }
            
            self.stepBackwardsButton.enabled = (_selectedDirectionIndex != 0);
            self.stepForwardsButton.enabled = (_selectedDirectionIndex < directions.graphics.count - 1);
        }
    }
}

- (CGFloat) getDetailsLabelHeight
{
    NSString *text = self.stepDetailsLabel.text;
    CGRect constraintFrame = CGRectMake(self.stepDetailsLabel.frame.origin.x, self.stepDetailsLabel.frame.origin.y,
                                        self.stepDetailsLabel.frame.size.width, self.stepDetailsLabel.superview.frame.size.height);
    CGFloat labelHeight = [text sizeWithFont:self.stepDetailsLabel.font constrainedToSize:constraintFrame.size].height;
    return labelHeight;// + self.topPadding + self.bottomPadding;
}
@end
