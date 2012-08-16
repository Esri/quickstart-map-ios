//
//  SXTBasemapPickerView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "STXPortalItemPickerView.h"
#import "STXHelper.h"

@protocol SXTBasemapPickerDelegate
- (void)basemapSelected:(STXBasemapType)basemapType;
-(void) basemapsPickerDidTapInfoButton:(id)basemapsPicker;
@end

@interface SXTBasemapPickerView : STXPortalItemPickerView {
	id<SXTBasemapPickerDelegate> basemapDelegate;
}

@property (nonatomic, strong) id basemapDelegate;
@property (nonatomic, assign) STXBasemapType basemapType;
@end
