//
//  NotificationViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/27.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationModel.h"
#import "MJRefresh.h"
#import "WebViewController.h"
#import "WeakifyStrongify.h"
#import "DataEngine.h"
#import "LoadingView.h"

@interface NotificationViewController ()

@property (nonatomic, strong) NSMutableArray<NotificationModel *> *tableData;

@property (assign, nonatomic) NSInteger nowPage;
@property (strong, nonatomic) UIView *loadingView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *checkAllItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Mark22"] style:UIBarButtonItemStyleDone target:self action:@selector(checkAll:)];
    self.navigationItem.rightBarButtonItem = checkAllItem;

    self.title = NSLocalizedString(@"Notifications", @"Title of notifications page");

    self.tableData = [[NSMutableArray alloc] init];
    self.clearsSelectionOnViewWillAppear = YES;
    self.nowPage = 0;

    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NotificationCell"];
    [self initRefresh];
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MarkAllRead

- (void)checkAll:(id)sender
{
    NSString *title = NSLocalizedString(@"Causion", @"");
    NSString *message = NSLocalizedString(@"Really want to mark all as read?", @"");
    NSString *cancelButtonTitle = NSLocalizedString(@"NO", @"");
    NSString *otherButtonTitles = NSLocalizedString(@"YES", @"");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (!self.loadingView) {
            self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];
            [self.view addSubview:self.loadingView];
        }
        self.loadingView.hidden = NO;
        NSString *lastReadAt = [self.tableData firstObject].updatedDateStr;

        weakify(self);
        [[DataEngine sharedEngine] markAllNotificationsReadedWithAccessToken:self.accessToken lastTime:lastReadAt completionHandler:^(BOOL done, NSError *error) {
            strongify(self);
            if (self.loadingView) self.loadingView.hidden = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NotificationCell"];
    }
    
    NotificationModel *noti = [self.tableData objectAtIndex:indexPath.row];

    cell.textLabel.text = noti.repoFullName;
    cell.detailTextLabel.text = noti.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationModel *noti = [self.tableData objectAtIndex:indexPath.row];
    WebViewController *vc = [[WebViewController alloc] init];

    vc.url = noti.url;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"readed", @"mark notification readed");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NotificationModel *noti = [self.tableData objectAtIndex:indexPath.row];
        [self.tableData removeObject:noti];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [[DataEngine sharedEngine] markReadedNotificationsWithAccessToken:self.accessToken threadId:noti.notiId completionHandler:^(BOOL done, NSError *error) {
            // do nothing
        }];
    }
}

#pragma mark - refresh

- (void)loadTableData
{
    weakify(self);
    [[DataEngine sharedEngine] getUserNotificationsWithAccessToken:self.accessToken page:(++self.nowPage) completionHandler:^(NSArray<NotificationModel *> *notifications, NSError *error) {
        strongify(self);
        if (error) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        if (self.nowPage == 1) {
            self.tableData = [[NSMutableArray alloc] initWithArray:notifications];
            [self.tableView.mj_header endRefreshing];
        } else {
            [self.tableData addObjectsFromArray:notifications];
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
/*
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        strongify(self);
        [self loadTableData];

    }];
*/
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    
}

@end
