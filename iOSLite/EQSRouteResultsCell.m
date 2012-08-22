//
//  EQSRouteResultsCell.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSRouteResultsCell.h"

@interface EQSRouteResultsCell ()
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stepNumberLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stepDetailsLabel;

@property (nonatomic, retain) UIColor *defaultBGCol;

@end

@implementation EQSRouteResultsCell

@synthesize directionGraphic = _directionGraphic;
@synthesize directionIndex = _directionIndex;

@synthesize stepNumberLabel = _stepNumberLabel;
@synthesize stepDetailsLabel = _stepDetailsLabel;

@synthesize defaultBGCol = _defaultBGCol;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.defaultBGCol = self.backgroundColor;
        self.directionIndex = -1;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//   directionGraphic:(AGSDirectionGraphic *)directionGraphic
//         stepNumber:(NSInteger)stepNumber
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self)
//    {
//        self.defaultBGCol = self.stepDetailsLabel.backgroundColor;
//        
//        self.directionGraphic = directionGraphic;
//    }
//    return self;
//}
//
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        self.stepDetailsLabel.backgroundColor = [UIColor greenColor];
    }
    else
    {
        self.stepDetailsLabel.backgroundColor = self.defaultBGCol;
    }
}

- (void) setDirectionGraphic:(AGSDirectionGraphic *)directionGraphic
{
    _directionGraphic = directionGraphic;
    self.stepDetailsLabel.text = directionGraphic.text;
}

- (void) setDirectionIndex:(NSUInteger)directionIndex
{
    _directionIndex = directionIndex;
    self.stepNumberLabel.text = [NSString stringWithFormat:@"%d", _directionIndex];
}

- (CGFloat) getHeight
{
    NSString *text = self.stepDetailsLabel.text;
    return [text sizeWithFont:self.stepDetailsLabel.font constrainedToSize:self.stepDetailsLabel.frame.size].height + (2 * self.stepDetailsLabel.frame.origin.y);
}
@end
