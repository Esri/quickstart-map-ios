//
//  EQSCandidateViewControllerBaseViewController.h
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/27/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

typedef enum {
    EQSCandidateViewTypePanelView,
    EQSCandidateViewTypeCalloutView
} EQSCandidateViewType;

@protocol EQSAddressCandidateViewDelegate <NSObject>
@required
- (void) candidateViewController:(id)candidateVC DidTapViewType:(EQSCandidateViewType)viewType;
@optional
- (void) directionsRequestedToCandidate:(id)candidateVC;
- (void) directionsRequestedFromCandidate:(id)candidateVC;
@end





typedef enum {
    EQSCandidateTypeFailedGeocode,
    EQSCandidateTypeForwardGeocode,
    EQSCandidateTypeReverseGeocode,
    EQSCandidateTypeGeolocation,
    EQSCandidateTypeDirectionsStart,
    EQSCandidateTypeDirectionsEnd
} EQSCandidateType;

@interface EQSAddressCandidateBaseViewController : UIViewController
@property (nonatomic, strong) AGSAddressCandidate *candidate;
@property (nonatomic, assign) EQSCandidateType candidateType;
@property (nonatomic, readonly) AGSPoint *candidateLocation;

@property (nonatomic, strong) AGSGraphic *graphic;

@property (weak, nonatomic) IBOutlet UILabel *primaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *latLonLabel;
@property (weak, nonatomic) IBOutlet UILabel *locatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (nonatomic, readonly) UILabel *refLabel;

@property (nonatomic, weak) id<EQSAddressCandidateViewDelegate> candidateViewDelegate;

- (void) prepareView;

+ (id) viewControllerWithCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType;
- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType;

@property (nonatomic, strong) NSString *latLonFormatString;
@end










@interface EQSDummyAddressCandidate : AGSAddressCandidate
- (id) initWithLocation:(AGSPoint *)location andSearchRadius:(double)searchRadius;
@property (nonatomic, strong, readonly) AGSPoint *dummyLocation;
@property (nonatomic, assign, readonly) double searchRadius;
@end

@interface AGSAddressCandidate (EQSAddressCandidateView)
- (BOOL) isDummyCandidate;
@end