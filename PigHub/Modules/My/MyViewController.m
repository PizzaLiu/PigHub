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
#import "NotificationViewController.h"

@interface MyViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UserModel *user;
@property (copy, nonatomic) NSString *accessToken;
@property (strong, nonatomic) UIView *loadingView;

@property (assign, nonatomic) NSInteger notiCount;

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

- (void)viewWillAppear:(BOOL)animated
{
    // init notification badge
    [self setNotificationBadge];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.user) {
        return 4;
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
                cell.textLabel.text = NSLocalizedString(@"Notifications", @"Notifications of github");
                if (self.notiCount > 0) {
                    cell.accessoryView = [self createCountLabelWithCount:self.notiCount];
                    cell.textLabel.textColor = [UIColor darkTextColor];
                } else {
                    cell.accessoryView = nil;
                    cell.textLabel.textColor = [UIColor grayColor];
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 3:
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
            // notifications
            if (indexPath.row == 2) {
                NotificationViewController *notiVc = [[NotificationViewController alloc] init];
                notiVc.hidesBottomBarWhenPushed = YES;
                notiVc.accessToken = self.accessToken;
                [self.navigationController pushViewController:notiVc animated:YES];
            } else
            // logout
            if (indexPath.row == 3) {
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // disable notification cell when no any notification
    if (indexPath.section == 0 && indexPath.row == 2 && self.notiCount <= 0) {
        return nil;
    }
        
    return indexPath;
}

-(UILabel *)createCountLabelWithCount:(NSInteger)count
{
    UILabel *label;
    CGFloat fontSize = 14;
    label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor redColor];

    label.text = [NSString stringWithFormat:@"%lu", (long)count];
    [label sizeToFit];

    // Adjust frame to be square for single digits or elliptical for numbers > 9
    CGRect frame = label.frame;
    frame.size.height += (int)(0.4*fontSize);
    frame.size.width = ((long)count <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
    label.frame = frame;

    // Set radius and clip to bounds
    label.layer.cornerRadius = frame.size.height/2.0;
    label.clipsToBounds = true;

    return label;
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

#pragma mark - badge

- (void)setNotificationBadge
{
    self.notiCount = [self.tabBarController.tabBar.selectedItem.badgeValue intValue];
    weakify(self);
    [[DataEngine sharedEngine] getUserNotificationsWithAccessToken:self.accessToken page:1 completionHandler:^(NSArray<NotificationModel *> *notifications, NSError *error) {
        strongify(self);
        self.notiCount = [notifications count];
        NSString *countStr = nil;
        if (self.notiCount > 0) {
            countStr = [NSString stringWithFormat:@"%lu", self.notiCount];
        }
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:countStr];
        if (self.tableView) [self.tableView reloadData];
    }];
}


@end
