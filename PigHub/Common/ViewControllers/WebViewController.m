//
//  WebViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/26.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "HTMLReader.h"
#import "WebViewController.h"
#import "LoadingView.h"

@interface WebViewController () <WKNavigationDelegate>

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Loading...", @"Title of loading page");

    self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];
    self.loadingView.hidden = NO;

    // web view
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    webView.navigationDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.view = webView;
    [self.view addSubview:self.loadingView];

    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL: url];
    [(WKWebView *)self.view loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebViewDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.loadingView.hidden = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.title = webView.title;
    self.loadingView.hidden = YES;
}

@end
