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

@interface MyViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UserModel *user;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSData *encodeUserData = [[NSUserDefaults standardUserDefaults] objectForKey:@"login_user"];
    if (encodeUserData) {
        self.user = (UserModel *)[NSKeyedUnarchiver unarchiveObjectWithData:encodeUserData];
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
        return 2;
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
            // logout
            if (indexPath.row == 1) {
                NSString *title = NSLocalizedString(@"Notification", @"Title for logout notification");
                NSString *message = NSLocalizedString(@"Are you sure?", @"Message for logout notification");
                NSString *cancelButtonTitle = NSLocalizedString(@"NO", @"Cancel button title for logout notification");
                NSString *confirmButtonTitle = NSLocalizedString(@"YES", @"Confirm button title for logout notification");
                UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:confirmButtonTitle, nil];
                [logoutAlert show];
            }
        }
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Login

- (void)oauth2LoginAction
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *reqUrl = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize/?client_id=%@&state=cool&scope=", GitHubClientID];

    LoginViewController *loginVc = [[LoginViewController alloc] init];
    loginVc.hidesBottomBarWhenPushed = YES;
    loginVc.url = reqUrl;

    weakify(self);
    loginVc.callback = ^(NSString *accessToken){
        if (!accessToken) return;

        // TODO: show loading here

        [[DataEngine sharedEngine] getUserInfoWithAccessToken:accessToken completionHandler:^(UserModel *user, NSError *error) {
            strongify(self);
            if (user) {
                self.user = user;
                [self.tableView reloadData];

                NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:self.user];
                [[NSUserDefaults standardUserDefaults] setObject:encodedUser forKey:@"login_user"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            // TODO: hide loading here
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
