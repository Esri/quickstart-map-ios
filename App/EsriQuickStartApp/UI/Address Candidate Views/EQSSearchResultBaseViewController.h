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
    EQSSearchResultViewTypePanelView,
    EQSSearchResultViewTypeCalloutView
} EQSSearchResultViewType;

@protocol EQSSearchResultViewDelegate <NSObject>
@required
- (void) searchResultViewController:(id)candidateVC DidTapViewType:(EQSSearchResultViewType)viewType;
@optional
- (void) directionsRequestedToCandidate:(id)candidateVC;
- (void) directionsRequestedFromCandidate:(id)candidateVC;
@end





typedef enum {
    EQSSearchResultTypeFailedGeocode,
    EQSSearchResultTypeForwardGeocode,
    EQSSearchResultTypeReverseGeocode,
    EQSSearchResultTypeGeolocation,
    EQSSearchResultTypeDirectionsStart,
    EQSSearchResultTypeDirectionsEnd
} EQSSearchResultType;

@interface EQSSearchResultBaseViewController : UIViewController
@property (nonatomic, strong) AGSAddressCandidate *candidate;
@property (nonatomic, strong) AGSLocatorFindResult *findResult;

@property (nonatomic, assign) EQSSearchResultType resultType;
@property (nonatomic, readonly) AGSPoint *resultLocation;
@property (nonatomic, readonly) CGFloat resultScore;

@property (nonatomic, strong) AGSGraphic *graphic;

@property (weak, nonatomic) IBOutlet UILabel *primaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *latLonLabel;
@property (weak, nonatomic) IBOutlet UILabel *locatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (nonatomic, readonly) UILabel *refLabel;

@property (nonatomic, weak) id<EQSSearchResultViewDelegate> searchResultViewDelegate;

- (void) prepareView;

+(id)viewControllerWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType;
-(id)initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType;

+(id)viewControllerWithFindResult:(AGSLocatorFindResult *)result OfType:(EQSSearchResultType)resultType;
-(id)initWithFindResult:(AGSLocatorFindResult *)result OfType:(EQSSearchResultType)resultType;

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