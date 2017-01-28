//
//  DataEngine.h
//  PigHub
//
//  Created by Rainbow on 2017/1/7.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Repository.h"
#import "UserModel.h"
#import "EventModel.h"
#import "AFNetworking.h"
#import "WeakifyStrongify.h"
#import "NotificationModel.h"

#pragma mark - AFAppDotNetAPIClient


@interface AFAppDotNetAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;
+ (instancetype)sharedHttpClient;

@end

#pragma mark - DataEngine

@interface DataEngine : NSObject

+(instancetype)sharedEngine;

- (void)getTrendingDataWithSince:(NSString *)since lang:(NSString *) lang isDeveloper:(BOOL)isDeveloper completionHandler:(void (^)(NSArray<Repository *> *repositories, NSError *error))completionHandler;

- (NSURLSessionDataTask *)searchRepositoriesWithPage:(NSInteger)page
                                               query:(NSString *)query
                                                sort:(NSString *)sort
                                   completionHandler:(void (^)(NSArray<Repository *> *repositories, NSError *error))completionBlock;
- (NSURLSessionDataTask *)searchUsersWithPage:(NSInteger)page
                                        query:(NSString *)query
                                         sort:(NSString *)sort
                            completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getAccessTokenWithCode:(NSString *)code
                               completionHandler:(void (^)(NSString *accessToken, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserInfoWithAccessToken:(NSString *)access_token
                                   completionHandler:(void (^)(UserModel *user, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserEventWithUserName:(NSString *)userName
                                       accessToken:(NSString *)access_token
                                              page:(NSInteger)page
                                 completionHandler:(void (^)(NSArray<EventModel *> *users, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserNotificationsWithAccessToken:(NSString *)access_token
                                                         page:(NSInteger)page
                                            completionHandler:(void (^)(NSArray<NotificationModel *> *notifications, NSError *error))completionBlock;
- (NSURLSessionDataTask *)markReadedNotificationsWithAccessToken:(NSString *)access_token
                                                        threadId:(NSString *)threadId
                                               completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)markAllNotificationsReadedWithAccessToken:(NSString *)access_token
                                                           lastTime:(NSString *)lastReadAt
                                                  completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;

@end
