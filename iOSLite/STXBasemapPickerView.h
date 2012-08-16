//
//  STXBasemapPickerView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "STXPortalItemPickerView.h"
#import "STXHelper.h"

@protocol STXBasemapPickerDelegate
- (void)basemapSelected:(STXBasemapType)basemapType;
-(void) basemapsPickerDidTapInfoButton:(id)basemapsPicker;
@end

@interface STXBasemapPickerView : STXPortalItemPickerView {
	id<STXBasemapPickerDelegate> basemapDelegate;
}

@property (nonatomic, strong) id basemapDelegate;
@property (nonatomic, assign) STXBasemapType basemapType;
@end
