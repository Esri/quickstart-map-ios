//
//  EQSCodeViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/21/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSCodeViewController.h"

#import "EQSCodeView.h"

@interface EQSCodeViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIWebView *codeWebView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;

@property (nonatomic, assign) BOOL docked;
@property (nonatomic, assign) CGRect dockedFrame;

@property (nonatomic, assign) CGSize webViewContentSize;
@property (nonatomic, assign) CGFloat controlHeight;

@property (nonatomic, strong) NSString *htmlTemplate;
@property (nonatomic, strong) NSDictionary *codeSnippets;

@property (nonatomic, readonly) NSString *currentSnippetTitle;

@property (weak, nonatomic) IBOutlet EQSCodeView *codeView;
- (IBAction)tabTapped:(id)sender;
@end

@implementation EQSCodeViewController
#define kEQSCodeSnippetItem_TitleKey @"title"
#define kEQSCodeSnippetItem_SnippetKey @"codeSnippet"
#define kEQSCodeSnippetItem_LinesKey @"highlightedLines"

@synthesize codeView;
@synthesize tabView;
@synthesize codeWebView;
@synthesize titleLabel;
@synthesize mainContainerView;

@synthesize htmlTemplate = _htmlTemplate;
@synthesize codeSnippets = _codeSnippets;

@synthesize webViewContentSize = _webViewContentSize;
@synthesize controlHeight = _controlHeight;

@synthesize docked = _docked;

@synthesize dockedFrame;

@synthesize currentAppState = _currentAppState;

@dynamic currentSnippetTitle;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do stuff when the web view loads (like resizing).
    self.codeWebView.delegate = self;

    // Load the HTML template that we'll use to show code snippets.
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"codeTemplate.html"];
    NSError *error = nil;
    self.htmlTemplate = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (error)
    {
        NSLog(@"Error loading HTML string for Code View");
        self.htmlTemplate = @"<html><head></head><body><h1>There was an error loading the code view.</h1><br/>%@</body></html>";
    }
    
    // Load the configuration file which contains the code snippets.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codeSnippets" ofType:@"plist"];
    NSData *pListData = [NSData dataWithContentsOfFile:path];
    NSString *configError;
    NSPropertyListFormat format;
    id pList = [NSPropertyListSerialization propertyListFromData:pListData
                                                mutabilityOption:NSPropertyListImmutable
                                                          format:&format
                                                errorDescription:&configError];
    
    if (pList)
    {
        if ([pList isKindOfClass:[NSDictionary class]])
        {
            self.codeSnippets = (NSDictionary *)pList;
        }
    }
    else 
    {
        NSLog(@"Error loading code snippets config: %@", error);
        self.codeSnippets = nil;
    }
}

- (void) refreshCodeSnippetViewerPosition;
{
    [self calculateDockedFrameForView];
    [self setCodeViewPosition:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self attachToRightEdgeOfMapView];
}

#define kcontrolsHeight 170
#define kverticalOffset 10

- (void) attachToRightEdgeOfMapView
{
    [self calculateDockedFrameForView];
    
    self.view.frame = self.dockedFrame;
    
    self.docked = YES;
}

- (void) calculateDockedFrameForView
{
    CGRect mapViewFrame = self.codeView.mapView.frame;
    
    CGFloat offSet = self.mainContainerView.frame.origin.x;
    // Set the position of this view to be just off to the side of the mapView so that the
    // CODE tab is visible and nothing else.
    self.dockedFrame = CGRectMake(mapViewFrame.origin.x + mapViewFrame.size.width - offSet,
                                  mapViewFrame.origin.y + kverticalOffset,
                                  mapViewFrame.size.width,
                                  self.controlHeight);
}

- (IBAction)tabTapped:(id)sender {
    self.docked = !self.docked;
}

- (void) setDocked:(BOOL)docked
{
    BOOL shouldUpdate = (_docked != docked);
    _docked = docked;
    if (shouldUpdate)
    {
        [self setCodeViewPosition];
    }
}

- (void) setCodeViewPosition
{
    [self setCodeViewPosition:YES];
}

- (void) setCodeViewPosition:(BOOL)withAnimation
{
    NSTimeInterval animationDuration = withAnimation?0.4:0;
    AGSMapView *mapView = self.codeView.mapView;
    if (mapView)
    {
        CGRect targetFrame = self.dockedFrame;
        if (!self.docked)
        {
            targetFrame = CGRectMake(mapView.frame.origin.x,
                                     mapView.frame.origin.y + kverticalOffset,
                                     mapView.frame.size.width,
                                     self.controlHeight);
        }
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.view.frame = targetFrame;
                         }];
    }
}

- (void) setCurrentAppState:(EQSSampleAppState)currentAppState
{
    _currentAppState = currentAppState;
    [self showCode];
}

- (NSString *)currentSnippetTitle
{
    switch (self.currentAppState) {
        case EQSSampleAppStateBasemaps:
		case EQSSampleAppStateBasemaps_Loading:
            return @"Basemaps";
        case EQSSampleAppStateGeolocation:
		case EQSSampleAppStateGeolocation_Locating:
		case EQSSampleAppStateGeolocation_GettingAddress:
            return @"Geolocation";
        case EQSSampleAppStateGraphics:
        case EQSSampleAppStateGraphics_Editing_Point:
        case EQSSampleAppStateGraphics_Editing_Line:
        case EQSSampleAppStateGraphics_Editing_Polygon:
            return @"Graphics";
        case EQSSampleAppStateFindPlace:
		case EQSSampleAppStateFindPlace_Finding:
		case EQSSAmpleAppStateFindPlace_GettingAddress:
            return @"FindPlace";
        case EQSSampleAppStateDirections:
        case EQSSampleAppStateDirections_WaitingForRouteStart:
        case EQSSampleAppStateDirections_WaitingForRouteEnd:
		case EQSSampleAppStateDirections_GettingRoute:
        case EQSSampleAppStateDirections_Navigating:
            return @"Directions";
        case EQSSampleAppStateCloudData:
            return @"Data";
    }
}

- (void) showCode
{
    // Load the base HTML file that we'll show in the web view.
	NSString *filePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:filePath isDirectory:YES];
    
    NSString *key = self.currentSnippetTitle;

    NSDictionary *codeSnippetData = [self.codeSnippets objectForKey:key];
    self.titleLabel.text = [codeSnippetData objectForKey:kEQSCodeSnippetItem_TitleKey];
    NSString *codeSnippet = [codeSnippetData objectForKey:kEQSCodeSnippetItem_SnippetKey];
    NSString *linesToHighlight = [codeSnippetData objectForKey:kEQSCodeSnippetItem_LinesKey];
    if (![linesToHighlight isEqualToString:@""])
    {
        linesToHighlight = [NSString stringWithFormat:@"highlight: [%@];", linesToHighlight];
    }
	
	// Set the HTML
    NSString *htmlToShow = [NSString stringWithFormat:self.htmlTemplate, linesToHighlight, codeSnippet];
//    NSLog(@"%@", htmlToShow);
    [self.codeWebView loadHTMLString:htmlToShow baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Trick the UIWebView into giving us the real required height for its width.
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    
    // And get the required size (we know the width, this is really just the height).
    CGSize webViewProposedSize = [webView sizeThatFits:CGSizeZero];

//    NSLog(@"1 %@", NSStringFromCGSize(webViewProposedSize));
//    NSLog(@"1 %@", NSStringFromCGRect(self.codeWebView.frame));
//    NSLog(@"1 %@", NSStringFromCGRect(self.view.frame));

    // Store the value.
    self.webViewContentSize = webViewProposedSize;
}

- (void) setWebViewContentSize:(CGSize)webViewContentSize
{
    // We store the value, but we do some more calculation.
    _webViewContentSize = webViewContentSize;
    
    // Work out the proposed height for the whole control, not just the WebView.
    CGFloat proposedHeight = _webViewContentSize.height + self.codeWebView.frame.origin.y;

    // At least tall enough to show the tab with buffering either side.
    CGFloat minHeight = (2 * self.tabView.frame.origin.y) + self.tabView.frame.size.height;
    if (proposedHeight < minHeight)
    {
        proposedHeight = minHeight;
    }
    
    // Work out whether it's more than we can handle.
    CGFloat maxHeight = self.codeView.mapView.frame.size.height - kcontrolsHeight - 2*kverticalOffset;
    if (proposedHeight > maxHeight)
    {
        proposedHeight = maxHeight;
    }
    
    // Set the control height.
    self.controlHeight = proposedHeight;
}

- (void) setControlHeight:(CGFloat)controlHeight
{
    // This is the height we'll display the whole Code View in.
    _controlHeight = controlHeight;
    
    // However, first we need to resize the height of the Web View to fit properly.
    CGRect frame = self.codeWebView.frame;
    frame.size.height = _controlHeight - self.codeWebView.frame.origin.y;
    self.codeWebView.frame = frame;
    
    // And now we refresh our display.
    [self calculateDockedFrameForView];
    [self setCodeViewPosition];
}
@end
