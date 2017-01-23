//
//  LoginViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/23.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "LoginViewController.h"
#import "DataEngine.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"GitHub Login", @"Title of login page");

    // loading view
    int loadingViewWidth = 80;
    int loadingViewHeight = 80;
    self.loadingView = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - loadingViewWidth)/2.0, (self.view.frame.size.height - loadingViewHeight)/2.0, loadingViewWidth, loadingViewHeight)];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    self.loadingView.layer.cornerRadius = 5;

    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(self.loadingView.frame.size.width / 2.0, 35);
    [activityView startAnimating];
    activityView.tag = 100;
    [self.loadingView addSubview:activityView];
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = NSLocalizedString(@"Loading...", @"loading web page");
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [self.loadingView addSubview:lblLoading];

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

- (NSString *)getOAuthCodeInURL:(NSURL *)url
{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url
                                                resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    NSString *key = @"code";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    NSString *code = nil;
    if (queryItem) {
        code = queryItem.value;
    }

    return code;
}

#pragma mark - WebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadingView.hidden = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *code = [self getOAuthCodeInURL:request.URL];

    if (code && self.callback) {

        weakify(self);
        [[DataEngine sharedEngine] getAccessTokenWithCode:code completionHandler:^(NSString *accessToken, NSError *error) {
            strongify(self);
            if (accessToken) {
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            self.loadingView.hidden = YES;
            self.callback(accessToken);
            [self.navigationController popViewControllerAnimated:YES];
        }];

        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadingView.hidden = YES;
}

@end
