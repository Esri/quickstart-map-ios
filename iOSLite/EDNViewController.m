//
//  EDNViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/8/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNViewController.h"

@interface EDNViewController ()

@end

@implementation EDNViewController
@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    AGSTiledMapServiceLayer *basemap = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"]];
    [self.mapView addMapLayer:basemap withName:@"Basemap"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapDidLoad:) name:@"MapViewDidLoad" object:self.mapView];
}

- (void)mapDidLoad:(NSNotification *)notification
{
    // Zoom to New York.
    [self.mapView zoomToLat:40.7302182289573 Long:-73.9958381652832 withScaleLevel:13];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

@end
