//
//  DataEngine.h
//  PigHub
//
//  Created by Rainbow on 2017/1/7.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepositoryModel.h"
#import "UserModel.h"
#import "EventModel.h"
#import "RepositoryInfoModel.h"
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

+ (instancetype)sharedEngine;

- (NSURLSessionDataTask *)getTrendingDataWithSince:(NSString *)since lang:(NSString *) lang isDeveloper:(BOOL)isDeveloper completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionHandler;

- (NSURLSessionDataTask *)searchRepositoriesWithPage:(NSInteger)page
                                               query:(NSString *)query
                                                sort:(NSString *)sort
                                   completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock;
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
- (NSURLSessionDataTask *)getUrlDataWithAccessToken:(NSString *)access_token
                                                url:(NSString *)url
                                  completionHandler:(void (^)(id data, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getRepoInfoWithOrgName:(NSString *)owner
                                        repoName:(NSString *)name
                               completionHandler:(void (^)(RepositoryInfoModel *data, NSError *error))completionBlock;
- (NSURLSessionDataTask *)checkIfStaredWithToken:(NSString *)access_token
                                       ownerName:(NSString *)owner
                                        repoName:(NSString *)repo
                               completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)staredRepoWithToken:(NSString *)access_token
                                    ownerName:(NSString *)owner
                                     repoName:(NSString *)repo
                            completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)unStaredRepoWithToken:(NSString *)access_token
                                      ownerName:(NSString *)owner
                                       repoName:(NSString *)repo
                              completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserInfoWithUserName:(NSString *)name
                                completionHandler:(void (^)(UserModel *data, NSError *error))completionBlock;
- (NSURLSessionDataTask *)checkIfFollowWithToken:(NSString *)access_token
                                        userName:(NSString *)name
                               completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)followUserWithToken:(NSString *)access_token
                                     userName:(NSString *)name
                            completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)unFollowUserWithToken:(NSString *)access_token
                                       userName:(NSString *)name
                              completionHandler:(void (^)(BOOL done, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserReposWithUserName:(NSString *)name
                                              page:(NSInteger)page
                                 completionHandler:(void (^)(NSArray<RepositoryModel *> *repos, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserFollowersWithAccessToken:(NSString *)accessToken
                                                     page:(NSInteger)page
                                        completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserFollowingsWithAccessToken:(NSString *)accessToken
                                                      page:(NSInteger)page
                                         completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserStarredsWithAccessToken:(NSString *)accessToken
                                                    page:(NSInteger)page
                                       completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserStarredsWithUserName:(NSString *)userName
                                                 page:(NSInteger)page
                                    completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getUserFollowingsWithUserName:(NSString *)username
                                                   page:(NSInteger)page
                                      completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock;
- (NSURLSessionDataTask *)getRepoReadmeWithOrgName:(NSString *)owner
                                          repoName:(NSString *)name
                                 completionHandler:(void (^)(NSDictionary *data, NSError *error))completionBlock;

@end
