//
//  RepositoryDetailViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/17.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "RepositoryDetailViewController.h"
#import "LoadingView.h"

@interface RepositoryDetailViewController() <UIWebViewDelegate>

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation RepositoryDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.repo.name;
    self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];

    // web view
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;

    self.view = webView;
    [self.view addSubview:self.loadingView];

    NSString *uri = self.repo.href;
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
