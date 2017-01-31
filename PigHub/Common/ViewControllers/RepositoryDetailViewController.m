//
//  RepositoryDetailViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/17.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "RepositoryDetailViewController.h"
#import "LoadingView.h"
#import "DataEngine.h"
#import "RepositoryInfoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utility.h"

@interface RepositoryDetailViewController() <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *ownerButton;
@property (weak, nonatomic) IBOutlet UIButton *repoButton;
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

@property (nonatomic, strong) RepositoryInfoModel *reopInfo;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, copy) NSString *accessToken;

@end

@implementation RepositoryDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.repo.name;
    self.loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];

    // avatar radius
    self.avatarImageView.layer.cornerRadius = 5.0;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5].CGColor;
    self.avatarImageView.layer.borderWidth = 0.3;

    // web view
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    //self.webView.scrollView.bounces = NO;
    //self.webView.scalesPageToFit = YES;


    //self.webView.intrinsicContentSize = CGSizeMake(0, 200.0);
    /*
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;

    self.view = webView;
    [self.view addSubview:self.loadingView];

    NSString *uri = self.repo.href;
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL: url];
    [(UIWebView *)self.view loadRequest:req];
     */

    [self.view addSubview:self.loadingView];
    self.loadingView.hidden = NO;

    self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];

    weakify(self);
    [[DataEngine sharedEngine] getRepoInfoWithOrgName:self.repo.orgName repoName:self.repo.name completionHandler:^(RepositoryInfoModel *data, NSError *error) {
        strongify(self);
        self.reopInfo = data;
        //self.loadingView.hidden = YES;
        [self initHeaderViewWithRepoInfo:data];
    }];

    /*
    [[DataEngine sharedEngine] checkIfStaredWithToken:accessToken ownerName:self.repo.orgName repoName:self.repo.name completionHandler:^(BOOL done, NSError *error) {
        if (done) {
            NSLog(@"YES");
        } else {
            NSLog(@"NO");
        }
    }];
     */
    /*
    [[DataEngine sharedEngine] staredRepoWithToken:accessToken ownerName:self.repo.orgName repoName:self.repo.name completionHandler:^(BOOL done, NSError *error) {
        if (done) {
            NSLog(@"YES");
        } else {
            NSLog(@"NO");
        }
    }];
     */
    /*
    [[DataEngine sharedEngine] unStaredRepoWithToken:self.accessToken ownerName:self.repo.orgName repoName:self.repo.name completionHandler:^(BOOL done, NSError *error) {
        if (done) {
            NSLog(@"YES");
        } else {
            NSLog(@"NO");
        }
    }];
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.repoButton setTitle:repoInfo.name forState:UIControlStateNormal];
    self.descLabel.text = repoInfo.desc;

    self.forkCountLabel.text = [Utility formatNumberForInt:repoInfo.forkCount];
    self.watchCountLabel.text = [Utility formatNumberForInt:repoInfo.watchCount];
    self.starCountLabel.text = [Utility formatNumberForInt:repoInfo.starCount];
    self.langLabel.text = repoInfo.lang;

    if (repoInfo.parent) {
        self.forkTextLabel.hidden = NO;
        self.forkRepoButton.hidden = NO;
        self.homepageButton.hidden = YES;
    } else {
        self.forkTextLabel.hidden = YES;
        self.forkRepoButton.hidden = YES;
        self.homepageButton.hidden = [repoInfo.homePage isEqualToString:@""];
        [self.homepageButton setTitle:repoInfo.homePage forState:UIControlStateNormal];
    }

    // load webview
    NSString *uri = repoInfo.readMeUrl;
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL: url];
    [self.webView loadRequest:req];


    CALayer *bottomBorder = [CALayer layer];
    CGFloat borderWidth = 1.0f / [UIScreen mainScreen].scale;
    bottomBorder.frame = CGRectMake(0.0f, self.headerView.frame.size.height - borderWidth, self.headerView.frame.size.width, borderWidth);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.25f alpha:0.25f].CGColor;
    [self.headerView.layer addSublayer:bottomBorder];

    //self.headerView.hidden = NO;
}

#pragma mark - Webview

- (void)addHeaderView:(UIView *)headerView
{
    UIView *webView = self.webView;
    CGRect browserCanvas = webView.bounds;
    CGFloat headerHeight = headerView.frame.size.height;

    CGRect subViewRect;
    for (UIView *subView in self.webView.scrollView.subviews) {
        subViewRect = subView.frame;
        if (subViewRect.origin.x == browserCanvas.origin.x &&
            subViewRect.origin.y == browserCanvas.origin.y &&
            subViewRect.size.width == browserCanvas.size.width &&
            subViewRect.size.height == browserCanvas.size.height) {

            subViewRect.origin.y = -200;//headerHeight;
            subViewRect.origin.x = 0;
            subViewRect.size.width = 360;
            subViewRect.size.height = 200;//headerHeight;
            subView.frame = subViewRect;
        }
    }

    [self.webView.scrollView addSubview:headerView];


    [self.webView.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:360]];
    [self.webView.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:200]];

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.webView.scrollView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0];
    [self.webView.scrollView addConstraint:constraint];
    [self.webView.scrollView bringSubviewToFront:headerView];
}

/*
 private func addHeaderView(headerView: UIView) {

 let browserCanvas = webView!.bounds

 for subView in webView!.scrollView.subviews {
 var subViewRect = subView.frame
 if(subViewRect.origin.x == browserCanvas.origin.x &&
   subViewRect.origin.y == browserCanvas.origin.y &&
   subViewRect.size.width == browserCanvas.size.width &&
   subViewRect.size.height == browserCanvas.size.height)
 {
 let height              = headerView.frame.size.height
 subViewRect.origin.y    = height
 subViewRect.size.height = height
 subView.frame           = subViewRect
 }
 }
 webView!.scrollView.addSubview(headerView)
 webView!.scrollView.bringSubviewToFront(headerView)
 }
 */

/*
 private func createHeaderView() -> UIView {
 let view = UILabel(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.frame), height: 50))
 view.text = "这是头部视图"
 view.backgroundColor = UIColor.orangeColor()
 return view
 }
 */

- (void)activateConstraintsForView:(UIView *)view respectToParentView:(UIView *)parentView
{
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:parentView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0];

    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:parentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0];

    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:parentView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];

    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:parentView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];

    // bottomConstraint = nil;
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:topConstraint, leftConstraint, bottomConstraint, rightConstraint, nil]] ;
}

- (UIView *) createHeaderView
{
    ///*
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, -200, 360, 200)];

    view.text = @"PizzaLiu";
    view.backgroundColor = [UIColor orangeColor];
    // */

    /*
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"RepositoryDetailHeaderView" owner:self options:nil].firstObject;

    view.frame = CGRectMake(0, -200, 360, 200);
    view.frame = CGRectMake(0, 0, 360, 200);
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
     */
    //[view layoutIfNeeded];

    return view;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // hide page header & footer
    NSString *cssString = @"body{background-color:white;} header,.reponav-wrapper,.blob-breadcrumb,footer { display:none!important; }";
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
    [webView stringByEvaluatingJavaScriptFromString:javascriptWithCSSString];


    [self.headerView removeFromSuperview];
    //self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(264.0, 0, 0, 0);
    //[self.webView.scrollView addSubview:self.headerView];
    //[self.headerView setBounds:CGRectMake(0, 0, 360.0, 200.0)];
    //self.webView.scrollView.bounces = NO;
    //[self.webView.scrollView setContentOffset: CGPointMake(0, self.webView.scrollView.contentInset.top) animated:NO];
    //self.webView.scalesPageToFit = YES;

    [self.webView.scrollView setContentOffset: CGPointMake(0, -264) animated:NO];

    ///UIView *header = [self createHeaderView];
    //[self.webView.scrollView addSubview:self.headerView];

    /*
    NSLayoutConstraint *aspectConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.headerView addConstraint:aspectConstraint];
     */

    //[self addHeaderView:self.headerView];
    [self.webView.scrollView addSubview:self.headerView];
    //self.headerView.backgroundColor = [UIColor grayColor];
    //self.headerView.frame = CGRectMake(0, 0, 360.0, 200.0);
    //[self.headerView setBounds:CGRectMake(0, 0, 360.0, 200.0)];



    self.headerView.hidden = NO;
    [self.headerView needsUpdateConstraints];
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];

    NSLog(@"%f", self.view.frame.size.width);
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:self.view.frame.size.width]];
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:200]];

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.webView.scrollView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:-200];
    [self.webView.scrollView addConstraint:constraint];

    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.webView.scrollView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0.0];
    [self.webView.scrollView addConstraint:constraintLeft];

    /*
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.webView.scrollView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0];
    [self.webView.scrollView addConstraint:constraintRight];
     */

    CGFloat height = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    //update the header's frame and set it again
    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.height = height;
    self.headerView.frame = headerFrame;

    [self.headerView setNeedsLayout];

    //header.frame = CGRectMake(0, -200, 360, 200);
    //[header layoutIfNeeded];
    ///[self activateConstraintsForView:self.headerView respectToParentView:self.webView];
    //self.headerView.frame = CGRectMake(0, -200, 360, 200);
    //self.headerView.hidden = NO;
    self.loadingView.hidden = YES;
    self.webView.hidden = NO;
}



@end
