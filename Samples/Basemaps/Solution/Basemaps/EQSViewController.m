//
//  EQSViewController.m
//  Basemaps
//
//  Created by Nicholas Furness on 11/29/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import <EsriQuickStart/EsriQuickStart.h>
#import "EQSViewController.h"

@interface EQSViewController ()
@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
@end

@implementation EQSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.mapView setBasemap:EQSBasemapTypeTopographic];
    [self.mapView zoomToLevel:15 withLat:40.7262 lon:-73.98186 animated:YES];
}

- (IBAction)basemapSelected:(id)sender {
    UISegmentedControl *basemapPicker = sender;
    
    EQSBasemapType newBasemapType = EQSBasemapTypeFirst;
    
    switch (basemapPicker.selectedSegmentIndex) {
        case 0:
            newBasemapType = EQSBasemapTypeTopographic;
            break;
        case 1:
            newBasemapType = EQSBasemapTypeStreet;
            break;
        case 2:
            newBasemapType = EQSBasemapTypeCanvas;
            break;
        case 3:
            newBasemapType = EQSBasemapTypeOpenStreetMap;
            break;
            
        default:
            NSLog(@"Unexpected basemap type index: %d", basemapPicker.selectedSegmentIndex);
            return;
    }
    
    [self.mapView setBasemap:newBasemapType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
