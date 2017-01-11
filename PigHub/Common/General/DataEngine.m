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

#pragma mark - AFAppDotNetAPIClient

static NSString * const AFAppDotNetAPIBaseURLString = @"https://api.github.com/";

@implementation AFAppDotNetAPIClient

+ (instancetype)sharedClient {
    static AFAppDotNetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAppDotNetAPIClient alloc] init];
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

#pragma mark - Utility

+ (NSString *)trimString:(NSString *) str
{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Github page

+ (void)getTrendingDataWithSince:(NSString *)since lang:(NSString *) lang isDeveloper:(BOOL)isDeveloper completionHandler:(void (^)(NSArray<Repository *> *repositories, NSError *error))completionBlock
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

    weakify(self);

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"User-Agent"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        strongify(self);

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
                repository.langName = [self trimString:[repo firstNodeMatchingSelector:@"[itemprop='programmingLanguage']"].textContent];
                repository.name = [self trimString:[link childAtIndex:2].textContent];
                repository.orgName = [self trimString:[[link childAtIndex:1].textContent stringByReplacingOccurrencesOfString:@"/" withString:@""]];
                repository.avatarUrl = [NSString stringWithFormat:@"https://github.com/%@.png", repository.orgName];
                repository.href = [link.attributes objectForKey:@"href"];
                repository.desc = [self trimString:[repo firstNodeMatchingSelector:@".py-1 p"].textContent];
                repository.starCount = [self trimString:[repo firstNodeMatchingSelector:@"[aria-label='Stargazers']"].textContent];

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

@end
