//
//  TrendingViewController.m
//  PigHub
//
//  Created by Rainbow on 2016/12/19.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import "TrendingViewController.h"
#import "SegmentBarView.h"
#import "LanguageViewController.h"
#import "LanguageModel.h"
#import "WeakifyStrongify.h"
#import "MJRefresh.h"
#import "DataEngine.h"
#import "Repository.h"
#import "RepositoryTableViewCell.h"
#import "FlyImage.h"

NSString * const SelectedLangQueryPrefKey = @"TrendingSelectedLangPrefKey";

@interface TrendingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet SegmentBarView *segmentBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sinceSigmentBar;
//@property (weak, nonatomic) UIImage *shadowImageView;
@property (weak, nonatomic) UIImageView *navHairline;

@property (strong, nonatomic) NSArray<Repository *> *tableData;
@property (strong, nonatomic) Language *targetLanguage;

@property (strong, nonatomic) NSString *sinceStr;

@end

@implementation TrendingViewController

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{SelectedLangQueryPrefKey: @""};

    [defaults registerDefaults:factorySettings];
}

- (instancetype)init
{
    self = [super init];

    self.tableData = [[NSMutableArray alloc] init];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navHairline = [self findNavBarHairline];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedLangQuery = [defaults objectForKey: SelectedLangQueryPrefKey];
    if (selectedLangQuery) {
        Language *selectedLang = [[LanguagesModel sharedStore] languageForQuery:selectedLangQuery];
        if (selectedLang) {
            self.targetLanguage = selectedLang;
        }
    }

    //if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //}
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(40, 0, 0, 0);

    //[self.tableView registerClass:[RepositoryTableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    UINib *nib = [UINib nibWithNibName:@"RepositoryTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UITableViewCell"];

    [self initRefresh];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navHairline setHidden:YES];

    if (self.targetLanguage) {
        self.navigationItem.title = self.targetLanguage.name;
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.navHairline setHidden:NO];

    __weak UIViewController *desVc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"LanguageSelector"]) {
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
                [defaults setObject:selectedLang.query forKey:SelectedLangQueryPrefKey];
            }
        };

        return ;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    Repository *repo = [self.tableData objectAtIndex:indexPath.row];

    cell.nameLabel.text = repo.name;
    cell.descLabel.text = repo.desc;
    cell.starLabel.text = repo.starCount;
    cell.ownerLabel.text = repo.orgName;
    cell.orderLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    cell.langLabel.text = repo.langName;

    [cell.avatarImage setPlaceHolderImageName:@"GithubLogo"
                          thumbnailURL:[NSURL URLWithString:[repo avatarUrlForSize:10]]
                           originalURL:[NSURL URLWithString:[repo avatarUrlForSize:50]]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RepositoryTableViewCell cellHeight];
}

- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(255);
    CGFloat g = arc4random_uniform(255);
    CGFloat b = arc4random_uniform(255);

    return [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1];
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

#pragma mark - refresh

- (void)initRefresh
{
    __unsafe_unretained UITableView *tableView = self.tableView;
    weakify(self);
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        strongify(self);
        [DataEngine getTrendingDataWithSince:self.sinceStr lang:self.targetLanguage.query isDeveloper:NO completionHandler:^(NSArray<Repository *> *repositories, NSError *error) {
            self.tableData = repositories;
            [self.tableView reloadData];
            [tableView.mj_header endRefreshing];
        }];

    }];
    //self.tableView.mj_header = header;

    tableView.mj_header.automaticallyChangeAlpha = YES;
    ((MJRefreshNormalHeader *)tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // header.stateLabel.hidden = YES;

    [tableView.mj_header beginRefreshing];
}

#pragma mark - segmentbar

- (IBAction)sinceSegmentChange:(id)sender {
    static NSArray *sinces;
    if (!sinces) {
        sinces = @[@"daily", @"weekly", @"monthly"];
    }
    NSInteger index = [sender selectedSegmentIndex];
    NSLog(@"change: %ld", (long)index);
    self.sinceStr = sinces[index];
    [self.tableView.mj_header beginRefreshing];
}

@end
