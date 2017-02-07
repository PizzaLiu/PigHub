//
//  RepositoryDetailViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/17.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "RepositoryDetailViewController.h"
#import "LoadingView.h"
#import "DataEngine.h"
#import "RepositoryInfoModel.h"
#import "UserDetailViewController.h"
#import "WebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utility.h"

@interface RepositoryDetailViewController() <WKNavigationDelegate>

{
    float topBlankHeight;
    float headerHeight;
    float scrollOffset;
}

@property (strong, nonatomic) WKWebView *wkWebView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *ownerButton;
@property (weak, nonatomic) IBOutlet UILabel *repoLabel;

@property (weak, nonatomic) IBOutlet UILabel *watchCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *forkCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *starCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *langLabel;
@property (weak, nonatomic) IBOutlet UILabel *forkTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *forkRepoButton;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *homepageButton;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDateLabel;

@property (nonatomic, strong) RepositoryInfoModel *repoInfo;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, copy) NSString *accessToken;

@property (assign, nonatomic) BOOL starred;

@property (assign, nonatomic) BOOL contentLoaded;

@end

@implementation RepositoryDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    self.title = self.repo.name;
    self.loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];
    self.contentLoaded = NO;

    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    // set avatar radius
    self.avatarImageView.layer.cornerRadius = 5.0;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5].CGColor;
    self.avatarImageView.layer.borderWidth = 0.3;

    // MKWebView

    // hide page header & footer
    NSString *cssString = @"body{background-color:white;} header,.reponav-wrapper,.blob-breadcrumb,footer { display:none!important; }";
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:javascriptWithCSSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:script];

    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    _wkWebView.navigationDelegate = self;
    _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_wkWebView belowSubview:_headerView];

    topBlankHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    headerHeight = _headerView.frame.size.height;
    scrollOffset = headerHeight + topBlankHeight;
    _wkWebView.scrollView.contentInset = UIEdgeInsetsMake(scrollOffset, 0, 0, 0);

    // loading view
    [self.view addSubview:self.loadingView];
    self.loadingView.hidden = NO;
    self.view.userInteractionEnabled = NO;

    weakify(self);

    [[DataEngine sharedEngine] getRepoInfoWithOrgName:self.repo.orgName repoName:self.repo.name completionHandler:^(RepositoryInfoModel *data, NSError *error) {
        strongify(self);
        self.repoInfo = data;
        [self initHeaderViewWithRepoInfo:data];
    }];

    [[DataEngine sharedEngine] getRepoReadmeWithOrgName:self.repo.orgName repoName:self.repo.name completionHandler:^(NSDictionary *data, NSError *error) {
        strongify(self);
        self.repoInfo.readmeUrl = [data objectForKey:@"html_url"];
        [self initContentViewWithUrlstr:[data objectForKey:@"html_url"]];
    }];


    if (self.accessToken && ![self.accessToken isEqualToString:@""]) {
        [[DataEngine sharedEngine] checkIfStaredWithToken:self.accessToken ownerName:self.repo.orgName repoName:self.repo.name completionHandler:^(BOOL starred, NSError *error) {
            strongify(self);
            self.starred = starred;
            [self addStarItemWithStarred:starred];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    _wkWebView.navigationDelegate = nil;
    [_wkWebView stopLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *url = navigationAction.request.URL.absoluteString;

    if (_contentLoaded) {
        decisionHandler(WKNavigationActionPolicyCancel);

        if (![url isEqualToString:self.repoInfo.readmeUrl]) {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.url = url;
            vc.hidesBottomBarWhenPushed = YES;

            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [_headerView removeFromSuperview];

    _wkWebView.scrollView.contentInset = UIEdgeInsetsMake(scrollOffset, 0, 0, 0);
    _wkWebView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topBlankHeight, 0, 0, 0);
    [_wkWebView.scrollView setContentOffset: CGPointMake(0, -scrollOffset) animated:NO];

    [_wkWebView.scrollView addSubview:self.headerView];

    // refix headerView constraint
    _headerView.hidden = NO;
    [_wkWebView.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_headerView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_wkWebView.scrollView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:-headerHeight]];
    [_wkWebView.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_headerView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_wkWebView.scrollView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    [_headerView addConstraint:[NSLayoutConstraint constraintWithItem:_headerView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:self.view.frame.size.width]];

    _contentLoaded = YES;
    self.view.userInteractionEnabled = YES;
    _wkWebView.hidden = NO;
    _loadingView.hidden = YES;
}

#pragma mark - InitView

-(void)initHeaderViewWithRepoInfo:(RepositoryInfoModel *)repoInfo
{
    if (!repoInfo) {
        return;
    }

    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[repoInfo.owner avatarUrlForSize:100]]
                        placeholderImage:[UIImage imageNamed:@"DefaultAvatar"]];
    [self.ownerButton setTitle:repoInfo.owner.name forState:UIControlStateNormal];
    self.repoLabel.text = repoInfo.name;
    self.descLabel.text = repoInfo.desc;

    self.forkCountLabel.text = [Utility formatNumberForInt:repoInfo.forkCount];
    self.watchCountLabel.text = [Utility formatNumberForInt:repoInfo.watchCount];
    self.starCountLabel.text = [Utility formatNumberForInt:repoInfo.starCount];
    self.langLabel.text = repoInfo.lang;

    self.createdDateLabel.text = [Utility getShortDayFromDate:repoInfo.createdDate];
    self.updatedDateLabel.text = [Utility getShortDayFromDate:repoInfo.updatedDate];

    if (repoInfo.parent) {
        self.homepageButton.hidden = YES;
        [self.forkRepoButton setTitle:[NSString stringWithFormat:@"%@/%@", repoInfo.parent.orgName, repoInfo.parent.name] forState:UIControlStateNormal];
    } else {
        self.forkTextLabel.hidden = YES;
        self.forkRepoButton.hidden = YES;
        self.homepageButton.hidden = [repoInfo.homePage isEqualToString:@""];
        [self.homepageButton setTitle:repoInfo.homePage forState:UIControlStateNormal];
    }

    // add botton border
    CALayer *bottomBorder = [CALayer layer];
    CGFloat borderWidth = 2.0f / [UIScreen mainScreen].scale;
    bottomBorder.frame = CGRectMake(0.0f, self.headerView.frame.size.height - borderWidth, self.headerView.frame.size.width, borderWidth);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.25f alpha:0.25f].CGColor;
    [self.headerView.layer addSublayer:bottomBorder];

    self.headerView.hidden = NO;
}

-(void)initContentViewWithUrlstr:(NSString *)uri
{
    // load webview
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL: url];
    [_wkWebView loadRequest:req];
}

- (void)addStarItemWithStarred:(BOOL)starred
{
    UIImage *img;
    if (starred) {
        img = [UIImage imageNamed:@"Star20"];
    } else {
        img = [UIImage imageNamed:@"StarPierced20"];
    }
    UIBarButtonItem *starItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(starAction:)];

    self.navigationItem.rightBarButtonItem = starItem;
}


#pragma mark - Actions

- (IBAction)starAction:(id)sender {

    if (!self.starred) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"Star20"];
        weakify(self);
        [[DataEngine sharedEngine] staredRepoWithToken:self.accessToken ownerName:self.repo.orgName repoName:self.repo.name completionHandler:^(BOOL done, NSError *error) {
            strongify(self);
            if (done) {
                self.starred = YES;
                self.repoInfo.starCount++;
                self.starCountLabel.text = [Utility formatNumberForInt:self.repoInfo.starCount];
            } else {
                self.starred = NO;
                self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"StarPierced20"];
            }
        }];
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"StarPierced20"];
        weakify(self);
        [[DataEngine sharedEngine] unStaredRepoWithToken:self.accessToken ownerName:self.repo.orgName repoName:self.repo.name completionHandler:^(BOOL done, NSError *error) {
            strongify(self);
            if (done) {
                self.starred = NO;
                self.repoInfo.starCount--;
                self.starCountLabel.text = [Utility formatNumberForInt:self.repoInfo.starCount];
            } else {
                self.starred = YES;
                self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"Star20"];
            }
        }];
    }
}

- (IBAction)showOwnerAction:(id)sender {
    UserDetailViewController *vc = [[UserDetailViewController alloc] init];
    vc.user = self.repoInfo.owner;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showHomepageAction:(id)sender {
    if (!self.repoInfo.homePage) return;

    WebViewController *vc = [[WebViewController alloc] init];
    vc.url = self.repoInfo.homePage;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showForkRepoAction:(id)sender {
    if (!self.repoInfo.parent) return;

    RepositoryDetailViewController *vc = [[RepositoryDetailViewController alloc] init];
    vc.repo = self.repoInfo.parent;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

@end
