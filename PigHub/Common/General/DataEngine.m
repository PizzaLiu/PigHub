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
    });

    return _sharedClient;
}

@end


#pragma mark - DataEngine

@interface DataEngine()


@end

@implementation DataEngine

#pragma mark - lifecycle

+(instancetype)sharedEngine
{
    static DataEngine *sharedEngine = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[self alloc] initPrivate];
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

- (void)getTrendingDataWithSince:(NSString *)since lang:(NSString *) lang isDeveloper:(BOOL)isDeveloper completionHandler:(void (^)(NSArray<Repository *> *repositories, NSError *error))completionBlock
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

    __unsafe_unretained AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    NSString *url = [[NSString alloc] initWithFormat:@"https://github.com/trending%@%@?since=%@", developer, langDir, since];

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"User-Agent"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSError *error = nil;
        NSMutableArray<Repository *> *repositories = nil;
        @try {
            NSString *markup = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            HTMLDocument *document = [HTMLDocument documentWithString:markup];
            NSArray<HTMLElement *> *repoList = [document nodesMatchingSelector:@".repo-list li"];

            repositories = [[NSMutableArray alloc] initWithCapacity:[repoList count]];
            Repository *repository = nil;
            HTMLElement *link = nil;
            for (HTMLElement *repo in repoList) {
                repository = [[Repository alloc] init];

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
            completionBlock([NSArray<Repository *> arrayWithArray:repositories], error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
}

#pragma mark - api

//https://developer.github.com/v3/search/#search-repositories
//Search repositories
- (NSURLSessionDataTask *)searchRepositoriesWithPage:(NSInteger)page
                                               query:(NSString *)query
                                                sort:(NSString *)sort
                                   completionHandler:(void (^)(NSArray<Repository *> *repositories, NSError *error))completionBlock
{
    NSString *getString = [NSString stringWithFormat:@"/search/repositories?q=%@&sort=%@&page=%ld",query,sort,(long)page];
    __unsafe_unretained AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    getString = [getString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            // NSInteger totalCount=[[responseObject objectForKey:@"total_count"] intValue];
            NSArray *list = [responseObject objectForKey:@"items"];
            if ([list isKindOfClass:[NSArray class]] && list.count > 0) {
                NSMutableArray<Repository *> *repositories = [[NSMutableArray alloc] init];
                Repository *repo = nil;
                for (NSInteger i = 0; i < list.count; i++) {
                    repo = [Repository modelWithDic:[list objectAtIndex:i]];
                    [repositories addObject:repo];
                }
                repo = nil;
                completionBlock(repositories, nil);
            } else {
                completionBlock(nil, responseObject);
            }
        } else {
            completionBlock(nil, responseObject);
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
    __unsafe_unretained AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];
    getString = [getString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
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
                completionBlock(nil, responseObject);
            }
        } else {
            completionBlock(nil, responseObject);
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
    __unsafe_unretained AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
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
    __unsafe_unretained AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager GET:getString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            UserModel *user = [UserModel modelWithDic:responseObject];
            completionBlock(user, responseObject);
        } else {
            completionBlock(nil, responseObject);
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
    __unsafe_unretained AFHTTPSessionManager *manager = [AFAppDotNetAPIClient sharedClient];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
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
            completionBlock(nil, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

    return task;
}

@end
