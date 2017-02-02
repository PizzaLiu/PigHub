//
//  FollowingUserViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/2/2.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "FollowingUserViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailViewController.h"
#import "MJRefresh.h"
#import "WeakifyStrongify.h"
#import "DataEngine.h"

@interface FollowingUserViewController ()

@property (nonatomic, strong) NSMutableArray<UserModel *> *tableData;

@property (nonatomic, assign) NSInteger userNowPage;

@end

@implementation FollowingUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableData = [[NSMutableArray alloc] initWithCapacity:0];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UINib *nib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FollowingUserCell"];

    self.clearsSelectionOnViewWillAppear = NO;

    [self initRefresh];
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowingUserCell" forIndexPath:indexPath];

    UserModel *user = [self.tableData objectAtIndex:indexPath.row];

    cell.user = user;
    cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.accessToken) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserModel *user = [self.tableData objectAtIndex:indexPath.row];
    UserDetailViewController *rdvc = [[UserDetailViewController alloc] init];
    rdvc.user = user;
    rdvc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:rdvc animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // unfollow a user
        UserModel *targetUser = [self.tableData objectAtIndex:indexPath.row];
        [[DataEngine sharedEngine] unFollowUserWithToken:self.accessToken userName:targetUser.name completionHandler:^(BOOL done, NSError *error) {
            // do nothing ...
        }];
        [self.tableData removeObject:targetUser];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"unfollow", @"unfollow a user");
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - refresh

- (void)loadStarRepos
{
    weakify(self);
    if (self.accessToken) {
        [[DataEngine sharedEngine] getUserFollowingsWithAccessToken:self.accessToken page:(self.userNowPage+1) completionHandler:^(NSArray<UserModel *> *users, NSError *error) {
            strongify(self);
            [self loadStarReposWithUsers:users];
        }];
    } else {
        [[DataEngine sharedEngine] getUserFollowingsWithUserName:self.userName page:(self.userNowPage+1) completionHandler:^(NSArray<UserModel *> *users, NSError *error) {
            strongify(self);
            [self loadStarReposWithUsers:users];
        }];
    }
}

- (void)loadStarReposWithUsers:(NSArray<UserModel *> *)users
{
    if ([users count] <= 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        return;
    } else {
        if (self.userNowPage == 0) {
            self.tableData = [[NSMutableArray alloc] initWithArray:users];
        } else {
            [self.tableData addObjectsFromArray:users];
        }
        [self.tableView reloadData];
        self.userNowPage++;
    }
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];

}

- (void)initRefresh
{
    weakify(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        strongify(self);
        self.userNowPage = 0;
        [self loadStarRepos];

    }];

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        strongify(self);
        [self loadStarRepos];

    }];

    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
}

@end
