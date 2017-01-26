//
//  LoginViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/23.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "LoginViewController.h"
#import "LoadingView.h"
#import "DataEngine.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"GitHub Login", @"Title of login page");

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
        self.loadingView.hidden = NO;
        weakify(self);

        [[DataEngine sharedEngine] getAccessTokenWithCode:code completionHandler:^(NSString *accessToken, NSError *error) {
            strongify(self);
            if (accessToken) {
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            self.callback(accessToken);
            //self.loadingView.hidden = YES;
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


@end
