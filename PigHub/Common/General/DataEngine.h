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
#import "AFNetworking.h"

#pragma mark - AFAppDotNetAPIClient


@interface AFAppDotNetAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

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

@end
