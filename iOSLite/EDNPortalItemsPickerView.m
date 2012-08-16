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
@synthesize topLevelView = _topLevelView;
@synthesize viewController = _viewController;

@synthesize pickerDelegate = _pickerDelegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EDNPortalItemsPickerView" owner:self options:nil];
		// This is solid in the designer so that we can, well,
		// see it to design it, but let's hide it at runtime.
		self.topLevelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
		
		// Load the nib contents into wherever we are in our parent.
		[self addSubview:self.topLevelView];
    }
    return self;
}

- (void)awakeFromNib
{
	// TODO - can this go in the initWithCoder?
	self.viewController.delegate = self;
}

#pragma mark - Passthrough public convenience functions.
// The control will be added as a UIView subtype, but we will have a proper controller
// doing all the actual controller work, it's just that the user won't see it.
- (AGSPortalItem *)currentPortalItem
{
	return self.viewController.currentPortalItem;
}

- (NSString *)currentPortalItemID
{
	return self.viewController.currentPortalItemID;
}

- (void)setCurrentPortalItemID:(NSString *)currentPortalItemID
{
	self.viewController.currentPortalItemID = currentPortalItemID;
}

- (AGSPortalItem *)addPortalItemByID:(NSString *)portalItemID
{
	return [self.viewController addPortalItemByID:portalItemID];
}

- (void)ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight
{
	[self.viewController ensureItemVisible:portalItemID Highlighted:highlight];
}

- (IBAction)infoButtonTapped:(id)sender
{
	// TODO - Move to ViewController
	if ([self.pickerDelegate respondsToSelector:@selector(basemapsPickerDidTapInfoButton:)])
	{
		[self.pickerDelegate basemapsPickerDidTapInfoButton:self];
	}
}
@end
