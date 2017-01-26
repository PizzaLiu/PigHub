//
//  WebViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/26.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "HTMLReader.h"
#import "WebViewController.h"
#import "LoadingView.h"

@interface WebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Loading...", @"Title of loading page");

    self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];

    // web view
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;

    self.view = webView;
    [self.view addSubview:self.loadingView];

    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL: url];
    [(UIWebView *)self.view loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.title || [self.title isEqualToString:NSLocalizedString(@"Loading...", @"Title of loading page")]) {
        NSString *htmlContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        HTMLDocument *document = [HTMLDocument documentWithString:htmlContent];
        self.title = [document firstNodeMatchingSelector:@"title"].textContent;
    }
    self.loadingView.hidden = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingView.hidden = NO;
}

@end
