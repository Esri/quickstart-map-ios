//
//  EQSCandidateViewControllerBaseViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/27/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <EsriQuickStart/EsriQuickStart.h>

#import "EQSSearchResultBaseViewController.h"

@interface EQSSearchResultBaseViewController ()
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelReverse;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelForward;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelGeolocate;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelDirectionsStart;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelDirectionsEnd;
@property (strong, nonatomic) IBOutlet UILabel *colorRefLabelGeocodeFailed;

@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (strong, nonatomic) IBOutlet UIView *candidateTypeRepresentationView;
@end

@implementation EQSSearchResultBaseViewController

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
@synthesize findResult = _findResult;
@synthesize resultType = _resultType;
@synthesize graphic = _graphic;

@dynamic resultLocation;
@dynamic refLabel;

@synthesize searchResultViewDelegate = _candidateViewDelegate;

@synthesize latLonFormatString = _latLonFormatString;

+ (id) viewControllerWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id) initWithAddressCandidate:(AGSAddressCandidate *)candidate OfType:(EQSSearchResultType)candidateType
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+(id)viewControllerWithFindResult:(AGSLocatorFindResult *)result OfType:(EQSSearchResultType)resultType;
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(id)initWithFindResult:(AGSLocatorFindResult *)result OfType:(EQSSearchResultType)resultType;
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (AGSPoint *)resultLocation
{
    if (self.candidate)
    {
        if ([self.candidate isKindOfClass:[EQSDummyAddressCandidate class]])
        {
            EQSDummyAddressCandidate *dummy = (EQSDummyAddressCandidate *)self.candidate;
            return dummy.dummyLocation;
        }
        return self.candidate.location;
    }
    else if (self.findResult)
    {
        return (AGSPoint *)self.findResult.graphic.geometry;
    }
    NSLog(@"No candidate or find result to get location for!");
    return nil;
}

-(CGFloat)resultScore
{
    if (self.candidate)
    {
        return self.candidate.score;
    }
    else if (self.findResult)
    {
        return self.findResult.score;
    }
    NSLog(@"No candidate or find result to get score for!");
    return 0;
}


- (void) setResultType:(EQSSearchResultType)resultType
{
    _resultType = resultType;
}

- (void)setCandidate:(AGSAddressCandidate *)candidate
{
    _candidate = candidate;
}

-(void)setFindResult:(AGSLocatorFindResult *)findResult
{
    _findResult = findResult;
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
    switch (self.resultType) {
        case EQSSearchResultTypeForwardGeocode:
            referenceTemplateLabel = self.colorRefLabelForward;
            break;
        case EQSSearchResultTypeReverseGeocode:
            referenceTemplateLabel = self.colorRefLabelReverse;
            break;
        case EQSSearchResultTypeGeolocation:
            referenceTemplateLabel = self.colorRefLabelGeolocate;
            break;
        case EQSSearchResultTypeDirectionsStart:
            referenceTemplateLabel = self.colorRefLabelDirectionsStart;
            break;
        case EQSSearchResultTypeDirectionsEnd:
            referenceTemplateLabel = self.colorRefLabelDirectionsEnd;
            break;
        case EQSSearchResultTypeFailedGeocode:
            referenceTemplateLabel = self.colorRefLabelGeocodeFailed;
            break;
        default:
            NSLog(@"Unexpected EQSSearchResultType: %d", self.resultType);
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
        
        if (self.candidate || self.findResult)
        {
            NSString *latLonString = [NSString stringWithFormat:self.latLonFormatString,
                                      self.resultLocation.latitude,
                                      self.resultLocation.longitude];
            NSString *scoreString = [NSString stringWithFormat:@"%.2f%%", self.resultScore];
            
            switch (self.resultType)
            {
                case EQSSearchResultTypeForwardGeocode:
                {
                    // Using the FindResult
                    NSString *locatorName = [self.findResult.graphic attributeAsStringForKey:@"Addr_type"];
                    
                    self.primaryLabel.text = [self.findResult.graphic attributeAsStringForKey:@"Match_addr"];
                    self.latLonLabel.text = latLonString;
                    self.locatorLabel.text = locatorName;
                    self.scoreLabel.text = scoreString;
                }
                    break;
                    
                case EQSSearchResultTypeReverseGeocode:
                case EQSSearchResultTypeGeolocation:
                case EQSSearchResultTypeDirectionsStart:
                case EQSSearchResultTypeDirectionsEnd:
                {
                    // Use the AGSAddressCandidate
                    NSDictionary *addData = self.candidate.address;
                    NSString *addStr = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                        [addData objectForKey:kEQSAddressCandidateAddressField],
                                        [addData objectForKey:kEQSAddressCandidateCityField],
                                        [addData objectForKey:kEQSAddressCandidateStateField],
                                        [addData objectForKey:kEQSAddressCandidateZipField]];
                    NSString *locatorName = [self.candidate.address objectForKey:@"Addr_type"];
                    
                    self.primaryLabel.text = addStr;
                    self.latLonLabel.text = latLonString;
                    self.locatorLabel.text = locatorName;
                    self.scoreLabel.text = @"";
                }
                    break;
                    
                case EQSSearchResultTypeFailedGeocode:
                {
                    self.primaryLabel.text = @"Unable to find address for location!";
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