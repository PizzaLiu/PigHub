//
//  SearchViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "SearchViewController.h"
#import "SegmentBarView.h"
#import "Repository.h"
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

@property (strong, nonatomic) NSMutableArray<Repository *> *repoTableData;
@property (strong, nonatomic) NSMutableArray<UserModel *> *userTableData;
@property (strong, nonatomic) NSMutableArray *tableData;

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

    self.tableData = [[NSMutableArray alloc] init];
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
        Repository *repo = [self.repoTableData objectAtIndex:indexPath.row];

        cell.nameLabel.text = repo.name;
        cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        cell.descLabel.text = repo.desc;
        cell.starLabel.text = repo.starCount;
        cell.ownerLabel.text = repo.orgName;
        cell.langLabel.text = repo.langName;
        [cell.avatarImage sd_setImageWithURL:[NSURL URLWithString:[repo avatarUrlForSize:42]]
                            placeholderImage:[UIImage imageNamed:@"DefaultAvatar"]];
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
        Repository *repo = [self.repoTableData objectAtIndex:indexPath.row];
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
    __unsafe_unretained UITableView *tableView = self.tableView;
    weakify(self);

    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [tableView reloadData];
        strongify(self);
        self.noticeLabel.hidden = YES;
        NSString *query = self.searchController.searchBar.text;

        if ([self.typeSigment selectedSegmentIndex] == 0) {
            [[DataEngine sharedEngine] searchRepositoriesWithPage:1 query:query sort:@"stars" completionHandler:^(NSArray<Repository *> *repositories, NSError *error) {
                if (error) {
                    self.noticeLabel.text = @"error occured in loading data";
                    self.noticeLabel.hidden = NO;
                } else if ([repositories count] <= 0) {
                    self.noticeLabel.text = @"no relatived data or being dissected";
                    self.noticeLabel.hidden = NO;
                }
                self.repoTableData = [NSMutableArray arrayWithArray:repositories];
                [tableView reloadData];
                [tableView.mj_header endRefreshing];
                self.repoNowPage = 1;
            }];
        } else {
            [[DataEngine sharedEngine] searchUsersWithPage:1 query:query sort:@"stars" completionHandler:^(NSArray<UserModel *> *users, NSError *error) {
                if (error) {
                    self.noticeLabel.text = @"error occured in loading data";
                    self.noticeLabel.hidden = NO;
                } else if ([users count] <= 0) {
                    self.noticeLabel.text = @"no relatived data or being dissected";
                    self.noticeLabel.hidden = NO;
                }
                self.userTableData = [NSMutableArray arrayWithArray:users];
                [tableView reloadData];
                [tableView.mj_header endRefreshing];
                self.userNowPage = 1;
            }];
        }

    }];

    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        strongify(self);
        NSString *query = self.searchController.searchBar.text;

        if ([self.typeSigment selectedSegmentIndex] == 0) {
            [[DataEngine sharedEngine] searchRepositoriesWithPage:(self.repoNowPage+1) query:query sort:@"stars" completionHandler:^(NSArray<Repository *> *repositories, NSError *error) {
                if (error) {
                    ;
                } else if ([repositories count] <= 0) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [self.repoTableData addObjectsFromArray:repositories];
                    [tableView reloadData];
                    self.repoNowPage++;
                }
                [tableView.mj_footer endRefreshing];
            }];
        } else {
            [[DataEngine sharedEngine] searchUsersWithPage:(self.userNowPage+1) query:query sort:@"stars" completionHandler:^(NSArray<UserModel *> *users, NSError *error) {
                if (error) {
                    ;
                } else if ([users count] <= 0) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                } else {
                    [self.userTableData addObjectsFromArray:users];
                    [tableView reloadData];
                    self.userNowPage++;
                }
                [tableView.mj_footer endRefreshing];
            }];
        }

    }];

    tableView.mj_header.automaticallyChangeAlpha = YES;
    tableView.mj_footer.automaticallyChangeAlpha = YES;
    ((MJRefreshNormalHeader *)tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;

    //[tableView.mj_header beginRefreshing];
}

#pragma mark - segmentbar

- (IBAction)typeSegmentChange:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}


@end
