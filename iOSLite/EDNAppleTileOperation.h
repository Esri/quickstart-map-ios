//
//  EDNAppleTileOperation.h
//  MapTest1
//
//  Created by Nicholas Furness on 3/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface EDNAppleTileOperation : NSOperation<AGSTileOperation>
- (id) initWithTile:(AGSTile *)tile target:(id)target action:(SEL)action;

@property (nonatomic, retain) AGSTile * tile;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@end
