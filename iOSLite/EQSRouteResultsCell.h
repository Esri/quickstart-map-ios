//
//  EQSRouteResultsCell.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/20/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface EQSRouteResultsCell : UITableViewCell
@property (nonatomic, assign) NSUInteger directionIndex;
@property (nonatomic, strong) AGSDirectionGraphic *directionGraphic;
- (CGFloat) getHeight;
@end
