//
//  SXTBasemapPickerView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNPortalItemsPickerView.h"
#import "EDNLiteHelper.h"

@protocol SXTBasemapPickerDelegate
- (void)basemapSelected:(EDNLiteBasemapType)basemapType;
-(void) basemapsPickerDidTapInfoButton:(id)basemapsPicker;
@end

@interface SXTBasemapPickerView : EDNPortalItemsPickerView {
	id<SXTBasemapPickerDelegate> basemapDelegate;
}

@property (nonatomic, strong) id basemapDelegate;
@property (nonatomic, assign) EDNLiteBasemapType basemapType;
@end
