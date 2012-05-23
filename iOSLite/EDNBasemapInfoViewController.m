//
//  EDNBasemapInfoViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNBasemapInfoViewController.h"

@interface EDNBasemapInfoViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)doneButtonClicked:(id)sender;
@end

@implementation EDNBasemapInfoViewController
@synthesize webView;
@synthesize portalItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.portalItem)
    {
        NSString *url = [NSString stringWithFormat:@"http://www.arcgis.com/home/item.html?id=%@", self.portalItem.itemId];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setPortalItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
