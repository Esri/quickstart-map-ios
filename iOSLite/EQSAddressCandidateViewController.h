//
//  EQSAddressCandidateViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@class EQSAddressCandidateView;
@class EQSAddressCandidateViewController;

typedef enum {
    EQSCandidateTypeForwardGeocode,
    EQSCandidateTypeReverseGeocode,
    EQSCandidateTypeGeolocation,
    EQSCandidateTypeDirectionsStart,
    EQSCandidateTypeDirectionsEnd
} EQSCandidateType;

typedef enum {
    EQSCandidateViewTypeView,
    EQSCandidateViewTypeCalloutView
} EQSCandidateViewType;



@protocol EQSAddressCandidateViewDelegate
- (void) candidateViewController:(EQSAddressCandidateViewController *)candidateVC
           DidTapViewType:(EQSCandidateViewType)viewType;
@end




@interface EQSAddressCandidateViewController : UIViewController <AGSInfoTemplateDelegate> {
    id <EQSAddressCandidateViewDelegate> candidateViewDelegate;
}

@property (nonatomic, strong) AGSAddressCandidate *candidate;
@property (nonatomic, assign) EQSCandidateType candidateType;
@property (nonatomic, strong) AGSGraphic *graphic;

@property (nonatomic, weak) id candidateViewDelegate;


- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType;


- (void) addToParentView:(UIView *)parentView relativeTo:(EQSAddressCandidateViewController *)previousView;

+ (EQSAddressCandidateViewController *) findRightmostItemIn:(UIScrollView *)parentView;

- (void) ensureMainViewVisibleInParentUIScrollView;


+ (void) setContentWidthOfScrollViewContainingCandidateViews:(UIScrollView *)containingScrollView
                                               UsingTemplate:(EQSAddressCandidateView *)templateView;
+ (CGFloat) getWidthOfNumber:(NSUInteger)numberOfViews
     OfAddressCandidateViews:(EQSAddressCandidateView *)templateView;
@end
