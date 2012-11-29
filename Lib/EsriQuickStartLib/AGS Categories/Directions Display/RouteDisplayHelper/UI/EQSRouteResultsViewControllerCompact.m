//
//  EQSRouteResultsViewControllerCompact.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 9/6/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsViewControllerCompact.h"
#import "EQSHelper_int.h"

@interface EQSRouteResultsViewController ()
- (void) direction:(AGSDirectionGraphic *)direction selectedFromRouteResult:(AGSRouteResult *)routeResult;
@end

@interface EQSRouteResultsViewControllerCompact ()
@property (nonatomic, assign) NSInteger selectedDirectionIndex;
@property (weak, nonatomic) IBOutlet UILabel *stepNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepMetricsLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeMetricsLabel;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *stepBackwardsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stepForwardsButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomToRouteButton;


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

- (void) awakeFromNib
{
    NSBundle *eqsBundle = [EQSHelper getEQSBundle];
    NSString *imagePath = [eqsBundle pathForResource:@"prev-dir-iphone" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    self.stepBackwardsButton.image = image;
    imagePath = [eqsBundle pathForResource:@"next-dir-iphone" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:imagePath];
    self.stepForwardsButton.image = image;
    imagePath = [eqsBundle pathForResource:@"zoom-to-route" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:imagePath];
    self.zoomToRouteButton.image = image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    NSLog(@"DidLoad: Zoom ButtonItem: %@", self.farfoo);
}

- (void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"WillAppear: Zoom ButtonItem: %@", self.farfoo);
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"DidAppear: Zoom ButtonItem: %@", self.farfoo);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         UIView *parentView = self.view.superview;
                         CGRect parentFrame = parentView.bounds;
                         CGFloat newHeight = UIInterfaceOrientationIsPortrait(toInterfaceOrientation)?110:95;
                         CGFloat newY = parentFrame.origin.y + parentFrame.size.height - newHeight;
                         
                         NSLog(@"BEFORE %@ :: %f :: %f", NSStringFromCGRect(parentFrame), newY, newHeight);

                         self.view.frame = CGRectMake(self.view.frame.origin.x,
                                                      newY,
                                                      self.view.frame.size.width,
                                                      newHeight);
                     }];
    [self sizeDetailsLabel];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIView *parentView = self.view.superview;
    CGRect parentFrame = parentView.bounds;
    CGFloat newHeight = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)?110:80;
    CGFloat newY = parentFrame.origin.y + parentFrame.size.height - newHeight;
    
    NSLog(@"AFTER %@ :: %f :: %f", NSStringFromCGRect(parentFrame), newY, newHeight);
}

- (void) sizeDetailsLabel
{
    // Auto-size the label to fit the text (this will set the height and width)
    self.stepDetailsLabel.numberOfLines = 0;
    [self.stepDetailsLabel sizeToFit];
    
    // Work out what the full width should be.
    CGRect pFrame = self.stepDetailsLabel.superview.frame;
    CGRect lFrame = self.stepDetailsLabel.frame;
    CGFloat lWidth = pFrame.size.width - lFrame.origin.x;
    
    // Update the label's frame to be max width. This ensures that if we subsequently
    // rotate from landscape to portrait when the label text does not fit the width,
    // that we don't end up shrunk because of our springs and struts to the right-hand-edge.
    self.stepDetailsLabel.frame = CGRectMake(lFrame.origin.x, lFrame.origin.y,
                                             lWidth, lFrame.size.height);
}

- (void)setRouteResult:(AGSRouteResult *)routeResult
{
    self.selectedDirectionIndex = -1;
    [super setRouteResult:routeResult];
    self.routeMetricsLabel.text = [NSString stringWithFormat:@"Total: %@ (%@)",
                                   NSStringFromAGSDirectionSetDistance(routeResult.directions),
                                   NSStringFromAGSDirectionSetTime(routeResult.directions)];

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
                [self sizeDetailsLabel];
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
