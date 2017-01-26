//
//  UserDetailViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "UserDetailViewController.h"
#import "LoadingView.h"

@interface UserDetailViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.user.name;

    self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];

    // web view
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;

    self.view = webView;
    [self.view addSubview:self.loadingView];

    NSString *uri = self.user.href;
    NSURL *url = [NSURL URLWithString:uri];
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
    self.loadingView.hidden = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingView.hidden = NO;
}

@end
