//
//  EDNBasemapsPicker.m
//  iOSLite
//
//  Created by Nicholas Furness on 8/14/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNPortalItemsPickerView.h"
#import "EDNPortalItemsPickerViewController.h"
#import "EDNPortalItemViewController.h"
#import "EDNPortalItemsListView.h"

@interface EDNPortalItemsPickerView()
@property (strong, nonatomic) IBOutlet UIView *topLevelView;
@property (strong, nonatomic) IBOutlet EDNPortalItemsPickerViewController *viewController;
@end

@implementation EDNPortalItemsPickerView
@synthesize topLevelView;
@synthesize viewController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EDNPortalItemsPickerView" owner:self options:nil];
		[self addSubview:self.topLevelView];
    }
    return self;
}
@end
