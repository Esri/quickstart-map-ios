//
//  EDNBasemapsListView.h
//  iOSLite
//
//  Created by Nicholas Furness on 6/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDNBasemapItemViewController.h"

@interface EDNBasemapsListView : UIView
- (void)addBasemapItem:(EDNBasemapItemViewController *)item;
- (void)ensureItemVisible:(EDNLiteBasemapType)basemapType Highlighted:(BOOL)highlight;
@end
