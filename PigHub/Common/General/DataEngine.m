//
//  DataEngine.m
//  PigHub
//
//  Created by Rainbow on 2017/1/7.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "DataEngine.h"
#import "AFNetworking.h"
#import "HTMLReader.h"
#import "WeakifyStrongify.h"
#import "AppConfig.h"
#import "Utility.h"

#pragma mark - AFAppDotNetAPIClient

static NSString * const AFAppDotNetAPIBaseURLString = @"https://api.github.com";

@implementation AFAppDotNetAPIClient

+ (instancetype)sharedClient {
    static AFAppDotNetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAppDotNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.requestSerializer.timeoutInterval = 30;
    });

    return _sharedClient;
}

+ (instancetype)sharedHttpClient {
    static AFAppDotNetAPIClient *_sharedHttpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHttpClient = [[AFAppDotNetAPIClient alloc] init];
        _sharedHttpClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

        _sharedHttpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sharedHttpClient.requestSerializer.timeoutInterval = 30;
        [_sharedHttpClient.requestSerializer setValue:@"" forHTTPHeaderField:@"User-Agent"];
    });

    return _sharedHttpClient;
}

@end


#pragma mark - DataEngine

@interface DataEngine()

@property (nonatomic, strong) NSError *noTargetDataError;

@end

@implementation DataEngine

#pragma mark - lifecycle

+(instancetype)sharedEngine
{
    static DataEngine *sharedEngine = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[self alloc] initPrivate];

        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Parse the target data was unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Cannot parse target dats.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Maybe the API of Github have changed?", nil)
                                   };
        sharedEngine.noTargetDataError = [NSError errorWithDomain:@"DataEngine"
                                    code:100
                                userInfo:userInfo];
    });

    return sharedEngine;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[DataEngine sharedEngine]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    return self;
}

#pragma mark - Github page

- (NSURLSessionDataTask *)getTrendingDataWithSince:(NSString *)since lang:(NSString *) lang isDeveloper:(BOOL)isDeveloper completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock
{
    // /trending/developers  /trending
    // /trending/css  /trending/php
    // ?since= daily weekly monthly
    NSString *langDir = @"";
    if (![lang isEqualToString:@""]) {
        langDir = [NSString stringWithFormat:@"/%@", lang];
    }
    NSString *developer = @"/developers";
    if (!isDeveloper) {
        developer = @"";
    }

    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedHttpClient];
    NSString *url = [[NSString alloc] initWithFormat:@"https://github.com/trending%@%@?since=%@", developer, langDir, since];

    NSURLSessionDataTask *task = [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSError *error = nil;
        NSMutableArray<RepositoryModel *> *repositories = nil;
        @try {
            NSString *markup = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            HTMLDocument *document = [HTMLDocument documentWithString:markup];
            NSArray<HTMLElement *> *repoList = [document nodesMatchingSelector:@".repo-list li"];

            repositories = [[NSMutableArray alloc] initWithCapacity:[repoList count]];
            RepositoryModel *repository = nil;
            HTMLElement *link = nil;
            for (HTMLElement *repo in repoList) {
                repository = [[RepositoryModel alloc] init];

                link = [repo firstNodeMatchingSelector:@"h3 a"];
                repository.langName = [Utility trimString:[repo firstNodeMatchingSelector:@"[itemprop='programmingLanguage']"].textContent];
                repository.name = [Utility trimString:[link childAtIndex:2].textContent];
                repository.orgName = [Utility trimString:[[link childAtIndex:1].textContent stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                repository.avatarUrl = [NSString stringWithFormat:@"https://github.com/%@.png", repository.orgName];
                repository.href = [NSString stringWithFormat:@"https://github.com%@", [link.attributes objectForKey:@"href"]];
                repository.desc = [Utility trimString:[repo firstNodeMatchingSelector:@".py-1 p"].textContent];
                repository.starCount = [Utility trimString:[repo firstNodeMatchingSelector:@"[aria-label='Stargazers']"].textContent];

                [repositories addObject:repository];
            }
            repository = nil;
            link = nil;
        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Parse html content of Github Trending page was unsuccessful.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Cannot parse the html content.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Maybe the HTML element of Github Trending page have changed?", nil)
                                       };
            error = [NSError errorWithDomain:@"getTrendingDataWithSince@DataEngine"
                                        code:303
                                    userInfo:userInfo];
        } @finally {
            completionBlock([NSArray<RepositoryModel *> arrayWithArray:repositories], error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

#pragma mark - Search

//https://developer.github.com/v3/search/#search-repositories
//Search repositories
- (NSURLSessionDataTask *)searchRepositoriesWithPage:(NSInteger)page
                                               query:(NSString *)query
                                                sort:(NSString *)sort
                                   completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/search/repositories?q=%@&sort=%@&page=%ld",query,sort,(long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    getString = [getString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            // NSInteger totalCount=[[responseObject objectForKey:@"total_count"] intValue];
            NSArray *list = [responseObject objectForKey:@"items"];
            if ([list isKindOfClass:[NSArray class]] && list.count > 0) {
                NSMutableArray<RepositoryModel *> *repositories = [[NSMutableArray alloc] init];
                RepositoryModel *repo = nil;
                for (NSInteger i = 0; i < list.count; i++) {
                    repo = [RepositoryModel modelWithDic:[list objectAtIndex:i]];
                    [repositories addObject:repo];
                }
                repo = nil;
                completionBlock(repositories, nil);
            } else {
                completionBlock(nil, [self.noTargetDataError copy]);
            }
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

//https://developer.github.com/v3/search/#search-users
//Search users
- (NSURLSessionDataTask *)searchUsersWithPage:(NSInteger)page
                                        query:(NSString *)query
                                         sort:(NSString *)sort
                            completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/search/users?q=%@&sort=%@&page=%ld",query,sort,(long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    getString = [getString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //NSInteger totalCount = [[responseObject objectForKey:@"total_count"] intValue];
            NSArray *list = [responseObject objectForKey:@"items"];
            if ([list isKindOfClass:[NSArray class]] && list.count > 0) {
                NSMutableArray<UserModel *> *users = [[NSMutableArray alloc] init];
                UserModel *user = nil;
                for (NSDictionary *item in list) {
                    user = [UserModel modelWithDic:item];
                    [users addObject:user];
                }
                user = nil;
                completionBlock(users, nil);
            } else {
                completionBlock(nil, [self.noTargetDataError copy]);
            }
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

#pragma mark - OAuth2

// https://developer.github.com/v3/oauth/#redirect-users-to-request-github-access
// get access_token with OAuth2 code
- (NSURLSessionDataTask *)getAccessTokenWithCode:(NSString *)code
                               completionHandler:(void (^)(NSString *accessToken, NSError *error))completionBlock
{
    NSString *postUrl = @"https://github.com/login/oauth/access_token";
    NSDictionary *parameters = @{
                                 @"client_id": GitHubClientID,
                                 @"client_secret": GitHubClientSecret,
                                 @"code": code,
                                 @"state": @"cool"
                                 };
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionDataTask *task = [manager POST:postUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *accessToken = [responseObject objectForKey:@"access_token"];
            completionBlock(accessToken, nil);
        } else {
            completionBlock(nil, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// https://developer.github.com/v3/oauth/#use-the-access-token-to-access-the-api
// get user info with access_token
- (NSURLSessionDataTask *)getUserInfoWithAccessToken:(NSString *)access_token
                                   completionHandler:(void (^)(UserModel *user, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user?access_token=%@", access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            UserModel *user = [UserModel modelWithDic:responseObject];
            completionBlock(user, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// https://developer.github.com/v3/activity/events/#list-public-events-that-a-user-has-received
// get user events with access_token
- (NSURLSessionDataTask *)getUserEventWithUserName:(NSString *)userName
                                       accessToken:(NSString *)access_token
                                              page:(NSInteger)page
                                   completionHandler:(void (^)(NSArray<EventModel *> *users, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/users/%@/received_events?access_token=%@&page=%lu", userName, access_token, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<EventModel *> *events = [[NSMutableArray alloc] init];
            EventModel *event = nil;
            for (NSDictionary *eventDic in responseObject) {
                event = [EventModel modelWithDic:eventDic];
                [events addObject:event];
            }
            event = nil;
            completionBlock(events, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

#pragma mark - Notification

// https://developer.github.com/v3/activity/notifications/#list-your-notifications
// get user notifications with access_token
- (NSURLSessionDataTask *)getUserNotificationsWithAccessToken:(NSString *)access_token
                                                         page:(NSInteger)page
                                            completionHandler:(void (^)(NSArray<NotificationModel *> *notifications, NSError *error))completionBlock
{
    // NSString *getString = [NSString stringWithFormat:@"/notifications?access_token=%@&page=%lu", access_token, (long)page];
    NSString *getString = [NSString stringWithFormat:@"/notifications?access_token=%@&t=%f", access_token, [[NSDate date] timeIntervalSince1970] * 1000];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<NotificationModel *> *notifications = [[NSMutableArray alloc] init];
            NotificationModel *noti = nil;
            for (NSDictionary *notiDic in responseObject) {
                noti = [NotificationModel modelWithDic:notiDic];
                [notifications addObject:noti];
            }
            noti = nil;
            completionBlock(notifications, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// https://developer.github.com/v3/activity/notifications/#mark-a-thread-as-read
// Mark a thread as read with access_token
- (NSURLSessionDataTask *)markReadedNotificationsWithAccessToken:(NSString *)access_token
                                                        threadId:(NSString *)threadId
                                               completionHandler:(void (^)(BOOL done, NSError *error))completionBlock
{
    NSString *patchString = [NSString stringWithFormat:@"https://api.github.com/notifications/threads/%@?access_token=%@", threadId, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedHttpClient];

    NSURLSessionDataTask *task = [manager PATCH:patchString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 205, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 205, nil);
    }];

    return task;
}

// https://developer.github.com/v3/activity/notifications/#mark-as-read
// Mark all as read with access_token
- (NSURLSessionDataTask *)markAllNotificationsReadedWithAccessToken:(NSString *)access_token
                                                           lastTime:(NSString *)lastReadAt
                                                  completionHandler:(void (^)(BOOL done, NSError *error))completionBlock
{
    NSString *putString = [NSString stringWithFormat:@"https://api.github.com/notifications?access_token=%@&last_read_at=%@", access_token, lastReadAt];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSURLSessionDataTask *task = [manager PUT:putString parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 205, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 205, nil);
    }];

    return task;
}

// Get url data with access_token
- (NSURLSessionDataTask *)getUrlDataWithAccessToken:(NSString *)access_token
                                                url:(NSString *)url
                                  completionHandler:(void (^)(id data, NSError *error))completionBlock
{
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

#pragma mark - Repository

// https://developer.github.com/v3/repos/#get
// Get repository detail
- (NSURLSessionDataTask *)getRepoInfoWithOrgName:(NSString *)owner
                                        repoName:(NSString *)name
                               completionHandler:(void (^)(RepositoryInfoModel *data, NSError *error))completionBlock
{
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@", owner, name];

    NSURLSessionDataTask *task = [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            completionBlock([RepositoryInfoModel modelWithDic:responseObject], nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// https://developer.github.com/v3/repos/#list-user-repositories
// List user repositories
- (NSURLSessionDataTask *)getUserReposWithUserName:(NSString *)name
                                              page:(NSInteger)page
                                 completionHandler:(void (^)(NSArray<RepositoryModel *> *repos, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/users/%@/repos?sort=updated&page=%lu", name, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<RepositoryModel *> *repos = [[NSMutableArray alloc] init];
            RepositoryModel *repo = nil;
            for (NSDictionary *repoDic in responseObject) {
                repo = [RepositoryModel modelWithDic:repoDic];
                [repos addObject:repo];
            }
            completionBlock(repos, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// https://developer.github.com/v3/repos/contents/#get-the-readme
// Get repository readme info
- (NSURLSessionDataTask *)getRepoReadmeWithOrgName:(NSString *)owner
                                          repoName:(NSString *)name
                                 completionHandler:(void (^)(NSDictionary *data, NSError *error))completionBlock
{
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/readme", owner, name];

    NSURLSessionDataTask *task = [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            completionBlock(responseObject, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

#pragma mark - Star

// List repositories being starred by the authenticated user.
// https://developer.github.com/v3/activity/starring/#list-repositories-being-starred
- (NSURLSessionDataTask *)getUserStarredsWithAccessToken:(NSString *)accessToken
                                                    page:(NSInteger)page
                                       completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/starred?sort=created&direction=desc&access_token=%@&page=%lu", accessToken, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<RepositoryModel *> *repos = [[NSMutableArray alloc] init];
            RepositoryModel *repo = nil;
            for (NSDictionary *repoDic in responseObject) {
                repo = [RepositoryModel modelWithDic:repoDic];
                [repos addObject:repo];
            }
            completionBlock(repos, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// List repositories being starred by a user.
// https://developer.github.com/v3/activity/starring/#list-repositories-being-starred
- (NSURLSessionDataTask *)getUserStarredsWithUserName:(NSString *)userName
                                                 page:(NSInteger)page
                                    completionHandler:(void (^)(NSArray<RepositoryModel *> *repositories, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/%@/starred?sort=created&direction=desc&page=%lu", userName, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<RepositoryModel *> *repos = [[NSMutableArray alloc] init];
            RepositoryModel *repo = nil;
            for (NSDictionary *repoDic in responseObject) {
                repo = [RepositoryModel modelWithDic:repoDic];
                [repos addObject:repo];
            }
            completionBlock(repos, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// Check if you are starring a repository
// https://developer.github.com/v3/activity/starring/#check-if-you-are-starring-a-repository
- (NSURLSessionDataTask *)checkIfStaredWithToken:(NSString *)access_token
                                       ownerName:(NSString *)owner
                                        repoName:(NSString *)repo
                               completionHandler:(void (^)(BOOL starred, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/starred/%@/%@?access_token=%@", owner, repo, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    }];

    return task;
}

// Star a repository
// https://developer.github.com/v3/activity/starring/#star-a-repository
- (NSURLSessionDataTask *)staredRepoWithToken:(NSString *)access_token
                                    ownerName:(NSString *)owner
                                     repoName:(NSString *)repo
                            completionHandler:(void (^)(BOOL done, NSError *error))completionBlock
{
    NSString *putString = [NSString stringWithFormat:@"/user/starred/%@/%@?access_token=%@", owner, repo, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager PUT:putString parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    }];

    return task;
}

// Unstar a repository
// https://developer.github.com/v3/activity/starring/#unstar-a-repository
- (NSURLSessionDataTask *)unStaredRepoWithToken:(NSString *)access_token
                                      ownerName:(NSString *)owner
                                       repoName:(NSString *)repo
                              completionHandler:(void (^)(BOOL done, NSError *error))completionBlock
{
    NSString *delString = [NSString stringWithFormat:@"/user/starred/%@/%@?access_token=%@", owner, repo, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager DELETE:delString parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    }];

    return task;
}

#pragma mark - User

// https://developer.github.com/v3/users/#get
// Get user detail
- (NSURLSessionDataTask *)getUserInfoWithUserName:(NSString *)name
                                completionHandler:(void (^)(UserModel *data, NSError *error))completionBlock
{
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    NSString *url = [NSString stringWithFormat:@"https://api.github.com/users/%@", name];

    NSURLSessionDataTask *task = [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            completionBlock([UserModel modelWithDic:responseObject], nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

#pragma mark - Follow

// List the authenticated user's followers
// https://developer.github.com/v3/users/followers/#list-followers-of-a-user
- (NSURLSessionDataTask *)getUserFollowersWithAccessToken:(NSString *)accessToken
                                                     page:(NSInteger)page
                                        completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/followers?access_token=%@&page=%lu", accessToken, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<UserModel *> *repos = [[NSMutableArray alloc] init];
            UserModel *user = nil;
            for (NSDictionary *userDic in responseObject) {
                user = [UserModel modelWithDic:userDic];
                [repos addObject:user];
            }
            completionBlock(repos, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// List who the authenticated user is following
// https://developer.github.com/v3/users/followers/#list-users-followed-by-another-user
- (NSURLSessionDataTask *)getUserFollowingsWithAccessToken:(NSString *)accessToken
                                                      page:(NSInteger)page
                                         completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/following?access_token=%@&page=%lu", accessToken, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<UserModel *> *users = [[NSMutableArray alloc] init];
            UserModel *user = nil;
            for (NSDictionary *userDic in responseObject) {
                user = [UserModel modelWithDic:userDic];
                [users addObject:user];
            }
            completionBlock(users, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// List who a user is following:
// https://developer.github.com/v3/users/followers/#list-users-followed-by-another-user
- (NSURLSessionDataTask *)getUserFollowingsWithUserName:(NSString *)username
                                                   page:(NSInteger)page
                                      completionHandler:(void (^)(NSArray<UserModel *> *users, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/%@/following?page=%lu", username, (long)page];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray<UserModel *> *users = [[NSMutableArray alloc] init];
            UserModel *user = nil;
            for (NSDictionary *userDic in responseObject) {
                user = [UserModel modelWithDic:userDic];
                [users addObject:user];
            }
            completionBlock(users, nil);
        } else {
            completionBlock(nil, [self.noTargetDataError copy]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

// Check if you are following a user
// https://developer.github.com/v3/users/followers/#check-if-you-are-following-a-user
- (NSURLSessionDataTask *)checkIfFollowWithToken:(NSString *)access_token
                                        userName:(NSString *)name
                               completionHandler:(void (^)(BOOL followed, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/user/following/%@?access_token=%@", name, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    }];

    return task;
}

// Follow a user
// https://developer.github.com/v3/users/followers/#follow-a-user
- (NSURLSessionDataTask *)followUserWithToken:(NSString *)access_token
                                     userName:(NSString *)name
                            completionHandler:(void (^)(BOOL done, NSError *error))completionBlock
{
    NSString *putString = [NSString stringWithFormat:@"/user/following/%@?access_token=%@", name, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager PUT:putString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    }];

    return task;
}

// Unfollow a user
// https://developer.github.com/v3/users/followers/#unfollow-a-user
- (NSURLSessionDataTask *)unFollowUserWithToken:(NSString *)access_token
                                       userName:(NSString *)name
                              completionHandler:(void (^)(BOOL done, NSError *error))completionBlock
{
    NSString *delString = [NSString stringWithFormat:@"/user/following/%@?access_token=%@", name, access_token];
    __weak AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    NSURLSessionDataTask *task = [manager DELETE:delString parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        completionBlock(statusCode == 204, nil);
    }];
    
    return task;
}

@end
