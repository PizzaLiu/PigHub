//
//  AboutViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/24.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "AboutViewController.h"
#import "RepositoryModel.h"
#import "RepositoryDetailViewController.h"
#import "UserModel.h"
#import "UserDetailViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"About", @"Title of about page");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)showRepoDetailWithRepo:(RepositoryModel *)repo
{
    RepositoryDetailViewController *vc = [[RepositoryDetailViewController alloc] init];
    vc.repo = repo;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showUserDetailWithUserMode:(UserModel *)user
{
    UserDetailViewController *vc = [[UserDetailViewController alloc] init];
    vc.user = user;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showMakerAction:(id)sender {
    UserModel *pizzaLiu = [UserModel new];

    pizzaLiu.name = @"PizzaLiu";
    pizzaLiu.href = @"https://github.com/PizzaLiu";

    [self showUserDetailWithUserMode:pizzaLiu];
}

- (IBAction)showSourceCodeAction:(id)sender {
    RepositoryModel *repo = [RepositoryModel new];

    repo.name = @"PigHub";
    repo.href = @"https://github.com/PizzaLiu/PigHub";
    repo.orgName = @"PizzaLiu";
    repo.name = @"PigHub";

    [self showRepoDetailWithRepo:repo];
}

- (IBAction)showAFNetworkingAction:(id)sender {
    RepositoryModel *repo = [RepositoryModel new];

    repo.name = @"AFNetworking";
    repo.href = @"https://github.com/AFNetworking/AFNetworking";
    repo.orgName = @"AFNetworking";
    repo.name = @"AFNetworking";

    [self showRepoDetailWithRepo:repo];
}
- (IBAction)showHTMLReaderAction:(id)sender {
    RepositoryModel *repo = [RepositoryModel new];

    repo.name = @"HTMLReader";
    repo.href = @"https://github.com/nolanw/HTMLReader";
    repo.orgName = @"nolanw";
    repo.name = @"HTMLReader";

    [self showRepoDetailWithRepo:repo];
}
- (IBAction)showMJRefreshAction:(id)sender {
    RepositoryModel *repo = [RepositoryModel new];

    repo.name = @"MJRefresh";
    repo.href = @"https://github.com/CoderMJLee/MJRefresh";
    repo.orgName = @"CoderMJLee";
    repo.name = @"MJRefresh";

    [self showRepoDetailWithRepo:repo];
}
- (IBAction)showSDWebImageAction:(id)sender {
    RepositoryModel *repo = [RepositoryModel new];

    repo.name = @"SDWebImage";
    repo.href = @"https://github.com/rs/SDWebImage";
    repo.orgName = @"rs";
    repo.name = @"SDWebImage";

    [self showRepoDetailWithRepo:repo];
}
- (IBAction)showDateToolsAction:(id)sender {
    RepositoryModel *repo = [RepositoryModel new];

    repo.name = @"DateTool";
    repo.href = @"https://github.com/MatthewYork/DateTools";
    repo.orgName = @"MatthewYork";
    repo.name = @"DateTools";

    [self showRepoDetailWithRepo:repo];
}

@end
