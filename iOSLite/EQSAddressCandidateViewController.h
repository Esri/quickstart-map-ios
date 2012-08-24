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

@protocol EQSAddressCandidateViewDelegate
- (void) candidateView:(EQSAddressCandidateView *)candidateView
 DidTapZoomToCandidate:(AGSAddressCandidate *)candidate;
@end

@interface EQSAddressCandidateViewController : UIViewController <AGSInfoTemplateDelegate> {
    id <EQSAddressCandidateViewDelegate> candidateViewDelegate;
}
@property (weak, nonatomic) IBOutlet EQSAddressCandidateView *addressCandidateView;
@property (nonatomic, strong) AGSAddressCandidate *candidate;
@property (nonatomic, weak) id candidateViewDelegate;

- (void) addToParentView:(UIView *)parentView relativeTo:(EQSAddressCandidateView *)previousView;
+ (void) setContentWidthOfScrollViewContainingCandidateViews:(UIScrollView *)containingScrollView UsingTemplate:(EQSAddressCandidateView *)templateView;
+ (CGFloat) getWidthOfNumber:(NSUInteger)numberOfViews OfAddressCandidateViews:(EQSAddressCandidateView *)templateView;

//+ (EQSAddressCandidateViewController *) addressCandidateViewControllerForCandidate:(AGSAddressCandidate *)candidate;
@end
