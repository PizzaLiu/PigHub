//
//  EventViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "EventViewController.h"
#import "LoadingView.h"
#import "DataEngine.h"
#import "MJRefresh.h"
#import "EventTableViewCell.h"
#import "UserDetailViewController.h"
#import "RepositoryDetailViewController.h"
#import "WebViewController.h"

@interface EventViewController ()

@property (assign, nonatomic) long nowPage;

@property (nonatomic, strong) NSMutableArray<EventModel *> *tableData;

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Events", @"Title of events page.");

    self.tableData = [[NSMutableArray alloc] init];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.nowPage = 0;

    UINib *nib = [UINib nibWithNibName:@"EventTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"EventTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self initRefresh];
    [self.tableView.mj_header beginRefreshing];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EventTableViewCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventTableViewCell" forIndexPath:indexPath];

    cell.eventModel = [self.tableData objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *targetCell = [tableView cellForRowAtIndexPath:indexPath];

    [targetCell becomeFirstResponder];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = [self getMenuItemsByEventModel:[self.tableData objectAtIndex:indexPath.row]];

    [menu setTargetRect:CGRectMake(0, 0, 2, 2) inView:targetCell];
    [menu setMenuVisible:YES animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}

#pragma mark - Menu Actions

- (NSArray<UIMenuItem *> *)getMenuItemsByEventModel:(EventModel *)event
{

    NSMutableArray<UIMenuItem *> *menues = [[NSMutableArray alloc] init];

    UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:event.actor.name action:@selector(showActorDetail:)];
    [menues addObject:menuItem1];

    UIMenuItem *menuItem2 = nil;
    NSString *repoFullPath = [NSString stringWithFormat:@"%@/%@", event.sourceRepo.orgName, event.sourceRepo.name];
    if (event.url) {
        menuItem2 = [[UIMenuItem alloc] initWithTitle:repoFullPath action:@selector(showWebPage:)];
    } else {
        menuItem2 = [[UIMenuItem alloc] initWithTitle:repoFullPath action:@selector(showSourceRepoDetail:)];
    }
    [menues addObject:menuItem2];

    if (event.destRepo) {
        UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@/%@", event.destRepo.orgName, event.destRepo.name] action:@selector(showDestRepoDetail:)];
        [menues addObject:menuItem3];
    }

    return menues;
}

- (void)showActorDetail:(id)sender
{
    EventModel *event = [self.tableData objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    UserDetailViewController *vc = [[UserDetailViewController alloc] init];
    vc.user = event.actor;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showWebPage:(id)sender
{
    EventModel *event = [self.tableData objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.url = event.url;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSourceRepoDetail:(id)sender
{
    EventModel *event = [self.tableData objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    RepositoryDetailViewController *vc = [[RepositoryDetailViewController alloc] init];
    vc.repo = event.sourceRepo;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showDestRepoDetail:(id)sender
{
    EventModel *event = [self.tableData objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    RepositoryDetailViewController *vc = [[RepositoryDetailViewController alloc] init];
    vc.repo = event.destRepo;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - refresh

- (void)loadTableData
{
    weakify(self);
    [[DataEngine sharedEngine] getUserEventWithUserName:self.loginedUser.name accessToken:self.accessToken page:(++self.nowPage) completionHandler:^(NSArray<EventModel *> *events, NSError *error) {
        strongify(self);
        if (error) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        if (self.nowPage == 1) {
            self.tableData = [[NSMutableArray alloc] initWithArray:events];
            [self.tableView.mj_header endRefreshing];
        } else {
            [self.tableData addObjectsFromArray:events];
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView reloadData];
    }];
}

- (void)initRefresh
{
    weakify(self);

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        strongify(self);
        self.nowPage = 0;
        [self.tableView reloadData];
        [self loadTableData];

    }];

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        strongify(self);
        // GitHub said: In order to keep the API fast for everyone, pagination is limited for this resource. Check the rel=last link relation in the Link response header to see how far back you can traverse.
        if (self.nowPage >= 10) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        [self loadTableData];

    }];

    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;

}


@end
