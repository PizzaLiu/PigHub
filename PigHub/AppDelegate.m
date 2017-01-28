//
//  AppDelegate.m
//  PigHub
//
//  Created by Rainbow on 2016/12/18.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import "AppDelegate.h"
#import "DataEngine.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.backgroundColor = [UIColor whiteColor];

    // init notification badge
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (accessToken) {
        weakify(self);
        [[DataEngine sharedEngine] getUserNotificationsWithAccessToken:accessToken page:1 completionHandler:^(NSArray<NotificationModel *> *notifications, NSError *error) {
            strongify(self);
            if (error) return;
            __weak UITabBarController *tabVc = (UITabBarController *)self.window.rootViewController;
            NSString *countStr = nil;
            NSInteger notiCount = [notifications count];
            if (notiCount > 0) {
                countStr = [NSString stringWithFormat:@"%lu", (long)notiCount];
            }
            [[tabVc.tabBar.items objectAtIndex:3] setBadgeValue:countStr];
        }];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
