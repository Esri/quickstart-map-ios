//
//  EQSCandidateViewControllerBaseViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/27/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <EsriQuickStart/EsriQuickStart.h>

#import "EQSAddressCandidateBaseViewController.h"

@interface EQSAddressCandidateBaseViewController ()
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelReverse;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelForward;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelGeolocate;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelDirectionsStart;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelDirectionsEnd;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelGeocodeFailed;

@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (strong, nonatomic) IBOutlet UIView *candidateTypeRepresentationView;
@end

@implementation EQSAddressCandidateBaseViewController

@synthesize colorRefLabelReverse;
@synthesize colorRefLabelForward;
@synthesize colorRefLabelGeolocate;
@synthesize colorRefLabelDirectionsStart;
@synthesize colorRefLabelDirectionsEnd;
@synthesize colorRefLabelGeocodeFailed;

@synthesize primaryLabel;
@synthesize latLonLabel;
@synthesize locatorLabel;
@synthesize scoreLabel;

@synthesize viewButton;
@synthesize candidateTypeRepresentationView;

@synthesize candidate = _candidate;
@synthesize candidateType = _candidateType;
@synthesize graphic = _graphic;

@dynamic candidateLocation;
@dynamic refLabel;

@synthesize candidateViewDelegate = _candidateViewDelegate;

@synthesize latLonFormatString = _latLonFormatString;

+ (id) viewControllerWithCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSCandidateType)candidateType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (AGSPoint *)candidateLocation
{
    if ([self.candidate isKindOfClass:[EQSDummyAddressCandidate class]])
    {
        EQSDummyAddressCandidate *dummy = (EQSDummyAddressCandidate *)self.candidate;
        return dummy.dummyLocation;
    }
    return self.candidate.location;
}


- (void) setCandidateType:(EQSCandidateType)candidateType
{
    _candidateType = candidateType;
}

- (void)setCandidate:(AGSAddressCandidate *)candidate
{
    _candidate = candidate;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.latLonFormatString = @"%.4f,%.4f";
	
    [self prepareView];
}

- (void)viewDidUnload
{
    [self setColorRefLabelReverse:nil];
    [self setColorRefLabelForward:nil];
    [self setColorRefLabelGeolocate:nil];
    [self setColorRefLabelDirectionsStart:nil];
    [self setColorRefLabelDirectionsEnd:nil];
    [self setColorRefLabelGeocodeFailed:nil];
    
    [self setPrimaryLabel:nil];
    [self setLatLonLabel:nil];
    [self setLocatorLabel:nil];
    [self setScoreLabel:nil];
    
    [self setViewButton:nil];

	[self setCandidateTypeRepresentationView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UILabel *)refLabel
{
    UILabel *referenceTemplateLabel = nil;
    switch (self.candidateType) {
        case EQSCandidateTypeForwardGeocode:
            referenceTemplateLabel = self.colorRefLabelForward;
            break;
        case EQSCandidateTypeReverseGeocode:
            referenceTemplateLabel = self.colorRefLabelReverse;
            break;
        case EQSCandidateTypeGeolocation:
            referenceTemplateLabel = self.colorRefLabelGeolocate;
            break;
        case EQSCandidateTypeDirectionsStart:
            referenceTemplateLabel = self.colorRefLabelDirectionsStart;
            break;
        case EQSCandidateTypeDirectionsEnd:
            referenceTemplateLabel = self.colorRefLabelDirectionsEnd;
            break;
        case EQSCandidateTypeFailedGeocode:
            referenceTemplateLabel = self.colorRefLabelGeocodeFailed;
            break;
        default:
            NSLog(@"Unexpected EQSCandidateType: %d", self.candidateType);
            break;
    }
    return referenceTemplateLabel;
}

- (void) prepareView
{
    if (self.view)
    {
        UILabel *refView = self.refLabel;
        
        self.candidateTypeRepresentationView.backgroundColor = refView.backgroundColor;
        
        if (self.candidate)
        {
            NSString *latLonString = [NSString stringWithFormat:self.latLonFormatString,
                                      self.candidateLocation.latitude,
                                      self.candidateLocation.longitude];
            NSString *scoreString = [NSString stringWithFormat:@"%.2f%%", self.candidate.score];
            
            switch (self.candidateType)
            {
                case EQSCandidateTypeForwardGeocode:
                {
                    NSString *locatorName = [self.candidate.attributes objectForKey:@"Addr_type"];
                    
                    self.primaryLabel.text =self.candidate.addressString;
                    //                self.secondaryLabel.text = @"";
                    self.latLonLabel.text = latLonString;
                    self.locatorLabel.text = locatorName;
                    self.scoreLabel.text = scoreString;
                }
                    break;
                    
                case EQSCandidateTypeReverseGeocode:
                case EQSCandidateTypeGeolocation:
                case EQSCandidateTypeDirectionsStart:
                case EQSCandidateTypeDirectionsEnd:
                {
                    NSDictionary *addData = self.candidate.address;
                    NSString *addStr = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                        [addData objectForKey:kEQSAddressCandidateAddressField],
                                        [addData objectForKey:kEQSAddressCandidateCityField],
                                        [addData objectForKey:kEQSAddressCandidateStateField],
                                        [addData objectForKey:kEQSAddressCandidateZipField]];
                    NSString *locatorName = [self.candidate.address objectForKey:@"Addr_type"];
                    
                    self.primaryLabel.text =addStr;
                    //                self.secondaryLabel.text = @"";
                    self.latLonLabel.text = latLonString;
                    self.locatorLabel.text = locatorName;
                    self.scoreLabel.text = @"";
                }
                    break;
                    
                case EQSCandidateTypeFailedGeocode:
                {
                    self.primaryLabel.text = @"Unable to find address for location!";
                    //                self.secondaryLabel.text = @"";
                    self.latLonLabel.text = latLonString;
                    self.locatorLabel.text = @"";
                    self.scoreLabel.text = @"";
                }
                    break;
                    
                default:
                    NSLog(@"Unknown Candidate View Type");
                    break;
            }
        }
        else
        {
            self.primaryLabel.text = @"";
            self.latLonLabel.text = @"";
            self.locatorLabel.text = @"";
            self.scoreLabel.text = @"";
        }
    }
}

@end



#pragma mark - Dummy Address Candidate
@implementation EQSDummyAddressCandidate
@synthesize dummyLocation = _dummyLocation;
@synthesize searchRadius = _searchRadius;

- (id) initWithLocation:(AGSPoint *)location andSearchRadius:(double)searchRadius
{
    self = [self init];
    if (self)
    {
        _dummyLocation = location;
        _searchRadius = searchRadius;
    }
    return self;
}
@end

@implementation AGSAddressCandidate (EQSAddressCandidateView)
- (BOOL) isDummyCandidate
{
    return [self isKindOfClass:[EQSDummyAddressCandidate class]];
}
@end