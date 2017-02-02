//
//  SearchViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "SearchViewController.h"
#import "SegmentBarView.h"
#import "RepositoryModel.h"
#import "UserModel.h"
#import "RepositoryTableViewCell.h"
#import "UserTableViewCell.h"
#import "MJRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WeakifyStrongify.h"
#import "DataEngine.h"
#import "RepositoryDetailViewController.h"
#import "UserDetailViewController.h"

@interface SearchViewController ()  <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchController *searchController;

@property (weak, nonatomic) IBOutlet SegmentBarView *segmentBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSigment;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) UIImageView *navHairline;

@property (strong, nonatomic) NSMutableArray<RepositoryModel *> *repoTableData;
@property (strong, nonatomic) NSMutableArray<UserModel *> *userTableData;

@property (assign, nonatomic) long repoNowPage;
@property (assign, nonatomic) long userNowPage;

@end

@implementation SearchViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;

    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = true;
    self.searchController.searchBar.showsCancelButton = NO;

    self.navigationItem.titleView = self.searchController.searchBar;

    self.definesPresentationContext = true;

    // other initial
    self.title = @"Search";

    self.repoNowPage = 1;

    self.navHairline = [self findNavBarHairline];

    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(104, 0, 48, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(104, 0, 48, 0);

    UINib *repoNib = [UINib nibWithNibName:@"RepositoryTableViewCell" bundle:nil];
    [self.tableView registerNib:repoNib forCellReuseIdentifier:@"RepoTableViewCell"];
    UINib *userNib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:userNib forCellReuseIdentifier:@"UserTableViewCell"];

    [self initRefresh];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.searchController.searchBar.text.length == 0) {
        [self.searchController.searchBar becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.delegate = self;

    if (self.searchController.searchBar.text.length > 0) {
        [self triggerContentShow:YES];
    } else {
        [self triggerContentShow:NO];
    }

    self.noticeLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self.typeSigment selectedSegmentIndex] == 0) {
        self.userTableData = nil;
    } else {
        self.repoTableData = nil;
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchController dismissViewControllerAnimated:YES completion:nil];

    if (searchBar.text.length > 0) {
        [self triggerContentShow:YES];
        [self.tableView.mj_header beginRefreshing];
    } else {
        [self triggerContentShow:NO];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchController.searchBar endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.typeSigment selectedSegmentIndex] == 0) {
        return [self.repoTableData count];
    }

    return [self.userTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.typeSigment selectedSegmentIndex] == 0) {
        RepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepoTableViewCell" forIndexPath:indexPath];
        RepositoryModel *repo = [self.repoTableData objectAtIndex:indexPath.row];

        cell.repo = repo;
        cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];

        return cell;
    }

    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell" forIndexPath:indexPath];
    UserModel *user = [self.userTableData objectAtIndex:indexPath.row];

    cell.nameLabel.text = user.name;
    cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    [cell.avatarImage sd_setImageWithURL:[NSURL URLWithString:[user avatarUrlForSize:44]]
                        placeholderImage:[UIImage imageNamed:@"DefaultAvatar"]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.typeSigment selectedSegmentIndex] == 0) {
        return [RepositoryTableViewCell cellHeight];
    }

    return [UserTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.typeSigment selectedSegmentIndex] == 0) {
        RepositoryModel *repo = [self.repoTableData objectAtIndex:indexPath.row];
        RepositoryDetailViewController *rdvc = [[RepositoryDetailViewController alloc] init];
        rdvc.repo = repo;
        rdvc.hidesBottomBarWhenPushed = YES;
        [self.navHairline setHidden:NO];
        [self.navigationController pushViewController:rdvc animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        UserModel *user = [self.userTableData objectAtIndex:indexPath.row];
        UserDetailViewController *udvc = [[UserDetailViewController alloc] init];
        udvc.user = user;
        udvc.hidesBottomBarWhenPushed = YES;
        [self.navHairline setHidden:NO];
        [self.navigationController pushViewController:udvc animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - navbar

- (UIImageView *)findNavBarHairline
{
    for (UIView *aView in self.navigationController.navigationBar.subviews) {
        for (UIView *bView in aView.subviews) {
            if ([bView isKindOfClass:[UIImageView class]] &&
                bView.bounds.size.width == self.navigationController.navigationBar.frame.size.width &&
                bView.bounds.size.height < 2) {
                return (UIImageView *)bView;
            }
        }
    }

    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y + self.tableView.contentInset.top;
    CGFloat panTranslationY = [scrollView.panGestureRecognizer translationInView:self.tableView].y;
    if (offsetY > 40) {
        // show in down scroll
        if (panTranslationY > 0) {
            [UIView animateWithDuration:0.5 animations:^{
                [self.segmentBar setAlpha:1.0];
                [self.navHairline setHidden:YES];
            }];
        }
        // hide in up scroll
        else {
            [UIView animateWithDuration:0.5 animations:^{
                [self.segmentBar setAlpha:0.0];
                [self.navHairline setHidden:NO];
            }];
        }
    } else {
        [self.navHairline setHidden:YES];
        [self.segmentBar setAlpha:1.0];
    }
}

#pragma mark - refresh

- (void)triggerContentShow:(BOOL)show
{
    if (show) {
        self.tableView.hidden = NO;
        self.navHairline.hidden = YES;
        self.segmentBar.hidden = NO;
        self.segmentBar.alpha = 1.0;
    } else {
        self.tableView.hidden = YES;
        self.navHairline.hidden = NO;
        self.segmentBar.hidden = YES;
        self.segmentBar.alpha = 0.0;
    }
}

- (void)initRefresh
{
    weakify(self);

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        strongify(self);
        [self.tableView reloadData];
        self.noticeLabel.hidden = YES;

        if ([self.typeSigment selectedSegmentIndex] == 0) {
            self.repoNowPage = 0;
            [self loadSearchReposData];
        } else {
            self.userNowPage = 0;
            [self loadSearchUsersData];
        }

    }];

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        strongify(self);

        if ([self.typeSigment selectedSegmentIndex] == 0) {
            [self loadSearchReposData];
        } else {
            [self loadSearchUsersData];
        }

    }];

    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
}


- (void)loadSearchReposData
{
    NSString *query = self.searchController.searchBar.text;
    weakify(self);
    [[DataEngine sharedEngine] searchRepositoriesWithPage:(self.repoNowPage+1) query:query sort:@"stars" completionHandler:^(NSArray<RepositoryModel *> *repositories, NSError *error) {
        strongify(self);
        self.noticeLabel.hidden = YES;
        if (error) {
            if (self.repoNowPage == 0) {
                self.noticeLabel.text = @"error occured in loading data";
                self.noticeLabel.hidden = NO;
            }
        } else if ([repositories count] <= 0) {
            if (self.repoNowPage == 0) {
                self.noticeLabel.text = @"no relatived data or being dissected";
                self.noticeLabel.hidden = NO;
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            if (self.repoNowPage == 0) {
                self.repoTableData = [[NSMutableArray alloc] initWithArray:repositories];
            } else {
                [self.repoTableData addObjectsFromArray:repositories];
            }
            [self.tableView reloadData];
            self.repoNowPage++;
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    }];

}

- (void)loadSearchUsersData
{
    NSString *query = self.searchController.searchBar.text;

    weakify(self);
    [[DataEngine sharedEngine] searchUsersWithPage:(self.userNowPage+1) query:query sort:@"stars" completionHandler:^(NSArray<UserModel *> *users, NSError *error) {
        strongify(self);
        self.noticeLabel.hidden = YES;
        if (error) {
            if (self.userNowPage == 0) {
                self.noticeLabel.text = @"error occured in loading data";
                self.noticeLabel.hidden = NO;
            }
        } else if ([users count] <= 0) {
            if (self.userNowPage == 0) {
                self.noticeLabel.text = @"no relatived data or being dissected";
                self.noticeLabel.hidden = NO;
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            if (self.userNowPage == 0) {
                self.userTableData = [[NSMutableArray alloc] initWithArray:users];
            } else {
                [self.userTableData addObjectsFromArray:users];
            }
            [self.tableView reloadData];
            self.userNowPage++;
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - segmentbar

- (IBAction)typeSegmentChange:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}


@end
