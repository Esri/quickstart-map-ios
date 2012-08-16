//
//  EDNBasemapInfoViewController.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "EDNBasemapDetailsViewController.h"

#define kEDNLiteAGSPortalItelURLBase @"http://www.arcgis.com/home/item.html?id=%@"

@interface EDNBasemapDetailsViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleLabel;

- (IBAction)doneButtonClicked:(id)sender;
@end

@implementation EDNBasemapDetailsViewController
@synthesize webView;
@synthesize titleLabel;
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
        self.title = self.portalItem.title;
        self.titleLabel.title = self.portalItem.title;
        NSString *url = [NSString stringWithFormat:kEDNLiteAGSPortalItelURLBase, self.portalItem.itemId];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
		self.webView.delegate = self;
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setPortalItem:nil];
    [self setTitleLabel:nil];
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

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}
@end
