//
//  MyViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/22.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "MyViewController.h"
#import "AppConfig.h"
#import "LoginViewController.h"
#import "DataEngine.h"
#import "UserModel.h"
#import "UserDetailViewController.h"
#import "AboutViewController.h"
#import "EventViewController.h"
#import "LoadingView.h"

@interface MyViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UserModel *user;
@property (copy, nonatomic) NSString *accessToken;
@property (strong, nonatomic) UIView *loadingView;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];

    NSData *encodeUserData = [[NSUserDefaults standardUserDefaults] objectForKey:@"login_user"];
    if (encodeUserData) {
        self.user = (UserModel *)[NSKeyedUnarchiver unarchiveObjectWithData:encodeUserData];
        self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    } else {
        self.user = nil;
    }

    self.title = NSLocalizedString(@"My", @"Title of My tab");
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.user) {
        return 3;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"About", @"About this application");
    } else {
        switch (indexPath.row) {
            case 0:
                if (self.user) {
                    cell.textLabel.text = self.user.name;
                } else {
                    cell.textLabel.text = NSLocalizedString(@"Login", @"Login by github OAuth2");
                }
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Events", @"Events of github");
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Logout", @"Login by github OAuth2");
                break;
            default:
                break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // login
        if (!self.user) {
            [self oauth2LoginAction];
        } else {
            // user detail
            if (indexPath.row == 0) {
                UserDetailViewController *userDetailVc = [[UserDetailViewController alloc] init];
                userDetailVc.user = self.user;
                userDetailVc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:userDetailVc animated:YES];
            } else
            // events
            if (indexPath.row == 1) {
                EventViewController *eventVc = [[EventViewController alloc] init];
                eventVc.hidesBottomBarWhenPushed = YES;
                eventVc.accessToken = self.accessToken;
                eventVc.loginedUser = self.user;
                [self.navigationController pushViewController:eventVc animated:YES];
            } else
            // logout
            if (indexPath.row == 2) {
                NSString *title = NSLocalizedString(@"Notification", @"Title for logout notification");
                NSString *message = NSLocalizedString(@"Are you sure?", @"Message for logout notification");
                NSString *cancelButtonTitle = NSLocalizedString(@"NO", @"Cancel button title for logout notification");
                NSString *confirmButtonTitle = NSLocalizedString(@"YES", @"Confirm button title for logout notification");
                UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:confirmButtonTitle, nil];
                [logoutAlert show];
            }
        }
    } else  {
        AboutViewController *aboutVc = [[AboutViewController alloc] init];
        aboutVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aboutVc animated:YES];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Login

- (void)oauth2LoginAction
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *reqUrl = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize/?client_id=%@&state=cool&scope=notifications,repo", GitHubClientID];

    LoginViewController *loginVc = [[LoginViewController alloc] init];
    loginVc.hidesBottomBarWhenPushed = YES;
    loginVc.url = reqUrl;

    weakify(self);
    loginVc.callback = ^(NSString *accessToken){
        if (!accessToken) return;

        strongify(self);
        self.loadingView.hidden = NO;

        [[DataEngine sharedEngine] getUserInfoWithAccessToken:accessToken completionHandler:^(UserModel *user, NSError *error) {
            if (user) {
                self.user = user;
                [self.tableView reloadData];

                NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:self.user];
                [[NSUserDefaults standardUserDefaults] setObject:encodedUser forKey:@"login_user"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            self.loadingView.hidden = YES;
        }];
    };

    [self.navigationController pushViewController:loginVc animated:YES];

}

- (void)logout
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"login_user"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.user = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self logout];
        [self.tableView reloadData];
    }
}


@end
