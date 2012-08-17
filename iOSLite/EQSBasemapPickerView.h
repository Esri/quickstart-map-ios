//
//  EQSBasemapPickerView.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSPortalItemPickerView.h"
#import "EQSHelper.h"

@protocol EQSBasemapPickerDelegate
- (void)basemapSelected:(EQSBasemapType)basemapType;
-(void) basemapsPickerDidTapInfoButton:(id)basemapsPicker;
@end

@interface EQSBasemapPickerView : EQSPortalItemPickerView {
	id<EQSBasemapPickerDelegate> basemapDelegate;
}

@property (nonatomic, strong) id basemapDelegate;
@property (nonatomic, assign) EQSBasemapType basemapType;
@end
