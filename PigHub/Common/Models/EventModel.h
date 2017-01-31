//
//  EventModel.h
//  PigHub
//
//  Created by Rainbow on 2017/1/24.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "RepositoryModel.h"

typedef NS_OPTIONS(NSUInteger, GitHubUserEventType) {
    GitHubUserEventTypeUnknow = 0,
    GitHubUserEventTypeFork = 1 << 0,
    GitHubUserEventTypeCreate = 1 << 1,
    GitHubUserEventTypeWatch = 1 << 2,
    GitHubUserEventTypeComment = 1 << 3,
    GitHubUserEventTypePull = 1 << 4,
    GitHubUserEventTypePush = 1 << 5,
    GitHubUserEventTypeIssue = 1 << 6,
};

@interface EventModel : NSObject

@property (nonatomic, assign) GitHubUserEventType eventType;
@property (nonatomic, strong) UserModel *actor;
@property (nonatomic, strong) RepositoryModel *sourceRepo;
@property (nonatomic, strong) RepositoryModel *destRepo;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *actionName;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) BOOL isPulic;

+ (instancetype)modelWithDic:(NSDictionary *)dic;

@end
