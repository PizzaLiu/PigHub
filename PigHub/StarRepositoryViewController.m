//
//  StarRepositoryViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/2/2.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "StarRepositoryViewController.h"
#import "RepositoryTableViewCell.h"
#import "RepositoryDetailViewController.h"
#import "MJRefresh.h"
#import "WeakifyStrongify.h"
#import "DataEngine.h"

@interface StarRepositoryViewController ()

@property (nonatomic, strong) NSMutableArray<RepositoryModel *> *tableData;

@property (nonatomic, assign) NSInteger repoNowPage;

@end

@implementation StarRepositoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableData = [[NSMutableArray alloc] initWithCapacity:0];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UINib *nib = [UINib nibWithNibName:@"RepositoryTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"StarRepoCell"];

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
    RepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarRepoCell" forIndexPath:indexPath];
    
    RepositoryModel *repo = [self.tableData objectAtIndex:indexPath.row];

    cell.repo = repo;
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
    RepositoryModel *repo = [self.tableData objectAtIndex:indexPath.row];
    RepositoryDetailViewController *rdvc = [[RepositoryDetailViewController alloc] init];
    rdvc.repo = repo;
    rdvc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:rdvc animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RepositoryTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // unstar a repo
        RepositoryModel *targetRepo = [self.tableData objectAtIndex:indexPath.row];
        [[DataEngine sharedEngine] unStaredRepoWithToken:self.accessToken ownerName:targetRepo.orgName repoName:targetRepo.name completionHandler:^(BOOL done, NSError *error) {
            // do nothing ...
        }];
        [self.tableData removeObject:targetRepo];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"unstar", @"unstar a repo");
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - refresh

- (void)loadStarRepos
{
    weakify(self);
    if (self.accessToken) {
        [[DataEngine sharedEngine] getUserStarredsWithAccessToken:self.accessToken page:(self.repoNowPage+1) completionHandler:^(NSArray<RepositoryModel *> *repositories, NSError *error) {
            strongify(self);
            [self loadStarReposWithRepositories:repositories];
        }];
    } else {
        [[DataEngine sharedEngine] getUserStarredsWithUserName:self.userName page:(self.repoNowPage+1) completionHandler:^(NSArray<RepositoryModel *> *repositories, NSError *error) {
            strongify(self);
            [self loadStarReposWithRepositories:repositories];
        }];
    }
}

- (void)loadStarReposWithRepositories:(NSArray<RepositoryModel *> *)repositories
{
    if ([repositories count] <= 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        return;
    } else {
        if (self.repoNowPage == 0) {
            self.tableData = [[NSMutableArray alloc] initWithArray:repositories];
        } else {
            [self.tableData addObjectsFromArray:repositories];
        }
        [self.tableView reloadData];
        self.repoNowPage++;
    }
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];

}

- (void)initRefresh
{
    weakify(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        strongify(self);
        self.repoNowPage = 0;
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
