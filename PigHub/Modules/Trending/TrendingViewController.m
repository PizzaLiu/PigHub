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

NSString * const SelectedLangQueryPrefKey = @"SelectedLangPrefKey";

@interface TrendingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet SegmentBarView *segmentBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIImage *shadowImageView;
@property (weak, nonatomic) UIImageView *navHairline;
@property (strong, nonatomic) Language *targetLanguage;

@end

@implementation TrendingViewController

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{SelectedLangQueryPrefKey: @""};

    [defaults registerDefaults:factorySettings];
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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

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

    UIViewController *desVc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"LanguageSelector"]) {
        LanguageViewController *lvc = (LanguageViewController *)desVc;
        lvc.selectedLanguageQuery = self.targetLanguage.query;

        weakify(self);
        lvc.dismissBlock = ^(Language *selectedLang){
            strongify(self);
            self.targetLanguage = selectedLang;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:selectedLang.query forKey:SelectedLangQueryPrefKey];
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
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [self randomColor];

    return cell;
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
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.tableView.mj_header endRefreshing];
    }];
    self.tableView.mj_header = header;

    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    // header.stateLabel.hidden = YES;

    [self.tableView.mj_header beginRefreshing];
}



@end
