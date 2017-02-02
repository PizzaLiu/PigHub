//
//  UserDetailViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import "UserDetailViewController.h"
#import "LoadingView.h"
#import "WebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utility.h"
#import "DataEngine.h"
#import "RepositoryTableViewCell.h"
#import "RepositoryDetailViewController.h"
#import "MJRefresh.h"

@interface UserDetailViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mailImageView;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *repoCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bioHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;


@property (nonatomic, strong) UserModel *myInfo;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) BOOL followed;
@property (nonatomic, assign) NSInteger nowRepoPage;
@property (nonatomic, strong) NSMutableArray *tableData;

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.user.name;

    self.nowRepoPage = 1;
    self.tableData = [[NSMutableArray alloc] init];

    self.loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];
    self.loadingView.hidden = NO;
    self.view.userInteractionEnabled = NO;
    [self.view addSubview:self.loadingView];

    if(!self.accessToken) self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSData *encodeUserData = [[NSUserDefaults standardUserDefaults] objectForKey:@"login_user"];
    if (encodeUserData) {
        self.myInfo = (UserModel *)[NSKeyedUnarchiver unarchiveObjectWithData:encodeUserData];
    } else {
        self.myInfo = nil;
    }

    // set avatar radius
    self.avatarImage.layer.cornerRadius = 5.0;
    self.avatarImage.layer.masksToBounds = YES;
    self.avatarImage.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5].CGColor;
    self.avatarImage.layer.borderWidth = 0.3;

    UINib *nib = [UINib nibWithNibName:@"RepositoryTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UserRepoCell"];
    [self initRefresh];

    weakify(self);
    [[DataEngine sharedEngine] getUserInfoWithUserName:self.user.name completionHandler:^(UserModel *data, NSError *error) {
        strongify(self);
        self.loadingView.hidden = YES;
        self.view.userInteractionEnabled = YES;
        if (data) {
            self.user = data;
            [self initHeaderWithUser:self.user];
        }
    }];

    if (self.accessToken && ![self.accessToken isEqualToString:@""]) {
        weakify(self);
        [[DataEngine sharedEngine] checkIfFollowWithToken:self.accessToken userName:self.user.name completionHandler:^(BOOL followed, NSError *error) {
            strongify(self);
            self.followed = followed;
            [self addFollowItemWithFollowed:followed];
            [self.tableView.mj_header beginRefreshing];
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Views

- (void)addFollowItemWithFollowed:(BOOL)followed
{
    if ([self.myInfo.name isEqualToString:self.user.name]) {
        return;
    }
    UIImage *img = [UIImage imageNamed:@"Follow20"];
    if (followed) {
        img = [UIImage imageNamed:@"Following20"];
    }
    UIBarButtonItem *followItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(followAction:)];

    self.navigationItem.rightBarButtonItem = followItem;
}

- (void)initHeaderWithUser:(UserModel *)user
{
    NSString *repoCountTitle = [NSString stringWithFormat:NSLocalizedString(@"All Public Repositories: %lu", @""), (long)user.reposCount];

    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[user avatarUrlForSize:100]] placeholderImage:[UIImage imageNamed:@"DefaultAvatar"]];

    self.fullNameLabel.text = user.fullName;
    self.nameLabel.text = user.name;
    self.bioLabel.text = user.bio;
    self.repoCountLabel.text = repoCountTitle;
    self.followerCountLabel.text = [Utility formatNumberForInt:user.followersCount];
    self.createdDateLabel.text = [Utility getShortDayFromDate:user.createdDate];

    if ([user.company isEqualToString:@""]) {
        self.groupLabel.text = @"null";
        self.groupLabel.hidden = YES;
        self.groupImageView.hidden = YES;
    } else {
        self.groupLabel.hidden = NO;
        self.groupImageView.hidden = NO;
        self.groupLabel.text = user.company;
    }

    if ([user.location isEqualToString:@""]) {
        self.locationLabel.text = @"Unknow";
    } else {
        self.locationLabel.text = user.location;
    }

    if ([user.email isEqualToString:@""]) {
        self.mailButton.hidden = YES;
        self.mailImageView.hidden = YES;
    } else {
        self.mailButton.hidden = NO;
        self.mailImageView.hidden = NO;
        [self.mailButton setTitle:user.email forState:UIControlStateNormal];
    }

    if ([user.blog isEqualToString:@""]) {
        self.linkButton.hidden = YES;
        self.linkImageView.hidden = YES;
    } else {
        self.linkButton.hidden = NO;
        self.linkImageView.hidden = NO;
        [self.linkButton setTitle:user.blog forState:UIControlStateNormal];
    }

    if ([user.bio isEqualToString:@""]) {
        self.bioHeightConstraint.constant = 0.0;
        self.bioLabel.hidden = YES;
    } else {
        self.bioLabel.hidden = NO;
    }

    self.headerView.hidden = NO;
    [self.headerView removeFromSuperview];
    self.tableView.tableHeaderView = self.headerView;

    // refix headerView constraint
    float headerHeight = self.headerView.frame.size.height;

    if ([user.bio isEqualToString:@""]) {
        headerHeight -= self.bioLabel.frame.size.height;
    }
    self.headerViewHeightConstraint.constant = headerHeight;
    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.height = headerHeight;
    self.headerView.frame = headerFrame;

    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:self.view.frame.size.width]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.tableView
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:0.0]];
    [self.headerView needsUpdateConstraints];
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRepoCell" forIndexPath:indexPath];

    RepositoryModel *repo = [self.tableData objectAtIndex:indexPath.row];
    cell.repo = repo;

    cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];

    if (repo.isForked) {
        cell.ownerLabel.text = NSLocalizedString(@"fork", @"Mark of fork repo");
    } else {
        cell.ownerLabel.text = NSLocalizedString(@"owner", @"Mark of own repo");
    }
    cell.avatarImage.hidden = YES;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RepositoryTableViewCell cellHeight];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryModel *repo = [self.tableData objectAtIndex:indexPath.row];
    RepositoryDetailViewController *rdvc = [[RepositoryDetailViewController alloc] init];
    rdvc.repo = repo;
    rdvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rdvc animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)loadReposData
{
    [[DataEngine sharedEngine] getUserReposWithUserName:self.user.name page:(++self.nowRepoPage) completionHandler:^(NSArray<RepositoryModel *> *repos, NSError *error) {
        if (!repos || repos.count <= 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableData addObjectsFromArray:repos];
            [self.tableView reloadData];

            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}

- (IBAction)followAction:(id)sender {
    UIImage *followingImg = [UIImage imageNamed:@"Following20"];
    UIImage *followImg = [UIImage imageNamed:@"Follow20"];
    UIBarButtonItem *rightItem = self.navigationItem.rightBarButtonItem;

    if (self.followed) {
        // unfollow
        rightItem.image = followImg;
        weakify(self);
        [[DataEngine sharedEngine] unFollowUserWithToken:self.accessToken userName:self.user.name completionHandler:^(BOOL done, NSError *error) {
            strongify(self);
            if (done) {
                self.followed = NO;
            } else {
                self.followed = YES;
                rightItem.image = followingImg;
            }
        }];
    } else {
        // follow
        rightItem.image = followingImg;
        weakify(self);
        [[DataEngine sharedEngine] followUserWithToken:self.accessToken userName:self.user.name completionHandler:^(BOOL done, NSError *error) {
            strongify(self);
            if (done) {
                self.followed = YES;
            } else {
                self.followed = NO;
                rightItem.image = followImg;
            }
        }];
    }
}

- (IBAction)sendMailAction:(id)sender {
    MFMailComposeViewController* vc = [[MFMailComposeViewController alloc] init];
    if (vc) {
        vc.mailComposeDelegate = self;
        [vc setToRecipients:@[self.user.email]];
        [vc setMessageBody:[NSString stringWithFormat:@"To %@,", self.user.fullName] isHTML:NO];
        [vc setModalPresentationStyle:UIModalPresentationPopover];

        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)openLinkAction:(id)sender {
    if (!self.user.blog) return;

    WebViewController *vc = [[WebViewController alloc] init];
    vc.url = self.user.blog;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - refresh

- (void)initRefresh
{
    weakify(self);

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        strongify(self);
        self.nowRepoPage = 0;
        [self.tableView reloadData];
        [self loadReposData];

    }];

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        strongify(self);
        [self loadReposData];

    }];

    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    
}


@end
