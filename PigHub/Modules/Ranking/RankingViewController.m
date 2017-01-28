//
//  RankingViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/20.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "RankingViewController.h"
#import "LanguageViewController.h"
#import "SegmentBarView.h"
#import "Repository.h"
#import "LanguageModel.h"
#import "MJRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WeakifyStrongify.h"
#import "DataEngine.h"
#import "RepositoryTableViewCell.h"
#import "RepositoryDetailViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailViewController.h"

NSString * const RankingSelectedLangQueryPrefKey = @"RankingSelectedLangPrefKey";

@interface RankingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet SegmentBarView *segmentBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSigment;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) UIImageView *navHairline;

@property (strong, nonatomic) NSMutableArray<Repository *> *repoTableData;
@property (strong, nonatomic) NSMutableArray<UserModel *> *userTableData;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) Language *targetLanguage;

@property (assign, nonatomic) long repoNowPage;
@property (assign, nonatomic) long userNowPage;

@end

@implementation RankingViewController

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{RankingSelectedLangQueryPrefKey: @""};

    [defaults registerDefaults:factorySettings];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ranking";

    self.tableData = [[NSMutableArray alloc] init];
    self.repoNowPage = 1;

    self.navHairline = [self findNavBarHairline];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedLangQuery = [defaults objectForKey: RankingSelectedLangQueryPrefKey];
    if (selectedLangQuery) {
        Language *selectedLang = [[LanguagesModel sharedStore] languageForQuery:selectedLangQuery];
        if (selectedLang) {
            self.targetLanguage = selectedLang;
        }
    }

    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(104, 0, 48, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(104, 0, 48, 0);

    //[self.tableView registerClass:[RepositoryTableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    UINib *repoNib = [UINib nibWithNibName:@"RepositoryTableViewCell" bundle:nil];
    [self.tableView registerNib:repoNib forCellReuseIdentifier:@"RepoTableViewCell"];
    UINib *userNib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [self.tableView registerNib:userNib forCellReuseIdentifier:@"UserTableViewCell"];

    [self initRefresh];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.delegate = self;

    if (self.segmentBar.alpha > 0) {
        [self.navHairline setHidden:YES];
    } else {
        [self.navHairline setHidden:NO];
    }

    if (self.targetLanguage) {
        self.navigationItem.title = self.targetLanguage.name;
    }

    self.noticeLabel.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.navHairline setHidden:NO];
    self.tableView.delegate = nil;

    __weak UIViewController *desVc = segue.destinationViewController;
    if ([segue.destinationViewController isKindOfClass:[LanguageViewController class]]) {
        LanguageViewController *lvc = (LanguageViewController *)desVc;
        lvc.selectedLanguageQuery = self.targetLanguage.query;

        weakify(self);
        lvc.dismissBlock = ^(Language *selectedLang){
            strongify(self);
            if (![self.targetLanguage.query isEqualToString:selectedLang.query]) {
                self.targetLanguage = selectedLang;
                self.tableData = nil;
                [self.tableView reloadData];
                [self.tableView.mj_header beginRefreshing];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:selectedLang.query forKey:RankingSelectedLangQueryPrefKey];
            }
        };

        return ;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self.typeSigment selectedSegmentIndex] == 0) {
        self.userTableData = nil;
    } else {
        self.repoTableData = nil;
    }
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
        [cell.avatarImage sd_setImageWithURL:[NSURL URLWithString:[repo avatarUrlForSize:50]]
                            placeholderImage:[UIImage imageNamed:@"GithubLogo"]];
        return cell;
    }

    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell" forIndexPath:indexPath];
    UserModel *user = [self.userTableData objectAtIndex:indexPath.row];

    cell.nameLabel.text = user.name;
    cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    [cell.avatarImage sd_setImageWithURL:[NSURL URLWithString:[user avatarUrlForSize:44]]
                        placeholderImage:[UIImage imageNamed:@"GithubLogo"]];

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

- (void)initRefresh
{
    __unsafe_unretained UITableView *tableView = self.tableView;
    weakify(self);

    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [tableView reloadData];
        strongify(self);
        self.noticeLabel.hidden = YES;

        if ([self.typeSigment selectedSegmentIndex] == 0) {
            [[DataEngine sharedEngine] searchRepositoriesWithPage:1 query:[NSString stringWithFormat:@"language:%@", self.targetLanguage.query] sort:@"stars" completionHandler:^(NSArray<Repository *> *repositories, NSError *error) {
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
            NSString *query;
            if ([self.targetLanguage.query isEqualToString:@""]) {
                query = @"repos:>1";
            } else {
                query = [NSString stringWithFormat:@"language:%@", self.targetLanguage.query];
            }
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

        if ([self.typeSigment selectedSegmentIndex] == 0) {
            [[DataEngine sharedEngine] searchRepositoriesWithPage:(self.repoNowPage+1) query:[NSString stringWithFormat:@"language:%@", self.targetLanguage.query] sort:@"stars" completionHandler:^(NSArray<Repository *> *repositories, NSError *error) {
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
            NSString *query;
            if ([self.targetLanguage.query isEqualToString:@""]) {
                query = @"repos:>1";
            } else {
                query = [NSString stringWithFormat:@"language:%@", self.targetLanguage.query];
            }
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

    [tableView.mj_header beginRefreshing];
}

#pragma mark - segmentbar

- (IBAction)typeSegmentChange:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}


@end
