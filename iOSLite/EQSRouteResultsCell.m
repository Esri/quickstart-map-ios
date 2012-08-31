//
//  EQSRouteResultsCell.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsCell.h"
#import "EQSHelper.h"

@interface EQSRouteResultsCell ()
@property (weak, nonatomic) IBOutlet UILabel *stepNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepDistanceLabel;

@property (nonatomic, retain) UIColor *defaultBGCol;

@property (nonatomic, assign) CGFloat topPadding;
@property (nonatomic, assign) CGFloat bottomPadding;
@end

@implementation EQSRouteResultsCell

@synthesize directionGraphic = _directionGraphic;
@synthesize directionIndex = _directionIndex;

@synthesize stepNumberLabel = _stepNumberLabel;
@synthesize stepDetailsLabel = _stepDetailsLabel;
@synthesize stepDistanceLabel = _stepDistanceLabel;

@synthesize defaultBGCol = _defaultBGCol;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.defaultBGCol = self.backgroundColor;
        self.topPadding = -1;
        self.bottomPadding = -1;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.topPadding = -1;
        self.bottomPadding = -1;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void) setDirectionGraphic:(AGSDirectionGraphic *)directionGraphic
{
    self.defaultBGCol = self.backgroundColor;
    self.stepDistanceLabel.hidden = (directionGraphic.maneuverType == AGSNADirectionsManeuverDepart ||
                                     directionGraphic.maneuverType == AGSNADirectionsManeuverStop);
    
    if (self.topPadding == -1)
    {
        self.topPadding = self.stepDetailsLabel.frame.origin.y;
        self.bottomPadding = self.frame.size.height - (self.stepDetailsLabel.frame.size.height +
                                                       self.stepDetailsLabel.frame.origin.y);
//        if (self.stepDistanceLabel.hidden)
//        {
//            CGFloat distanceLabelHeightAndPadding = self.frame.size.height - self.stepDistanceLabel.frame.origin.y;
//            self.bottomPadding = self.bottomPadding - distanceLabelHeightAndPadding;
//        }
    }
    
    self.stepNumberLabel.hidden = NO; //directionGraphic.maneuverType == AGSNADirectionsManeuverDepart;

    _directionGraphic = directionGraphic;
    self.stepDetailsLabel.text = directionGraphic.text;
    if (!self.stepDistanceLabel.hidden)
    {
        self.stepDistanceLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                       NSStringFromAGSDirectionGraphicDistance(directionGraphic),
                                       NSStringFromAGSDirectionGraphicTime(directionGraphic)];
    }
}

- (void) setDirectionIndex:(NSUInteger)directionIndex
{
    _directionIndex = directionIndex;
    self.stepNumberLabel.text = [NSString stringWithFormat:@"%d", _directionIndex + 1];
}

- (CGFloat) getHeight
{
    NSString *text = self.stepDetailsLabel.text;
    CGFloat labelHeight = [text sizeWithFont:self.stepDetailsLabel.font constrainedToSize:self.stepDetailsLabel.frame.size].height;
    return labelHeight + self.topPadding + self.bottomPadding;
}
@end