//
//  RepositoryInfoModel.h
//  PigHub
//
//  Created by Rainbow on 2017/1/29.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "RepositoryModel.h"

@interface RepositoryInfoModel : NSObject

@property (nonatomic, copy) NSString *repoId;
@property (nonatomic, strong) UserModel *owner;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *homePage;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) NSInteger starCount;
@property (nonatomic, assign) NSInteger forkCount;
@property (nonatomic, assign) NSInteger watchCount;

@property (nonatomic, strong) RepositoryModel *parent;

@property (nonatomic, copy) NSString *htmlUrl;
@property (nonatomic, copy) NSString *readmeUrl;
@property (nonatomic, copy) NSString *defaultBranch;

@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *updatedDate;

+ (instancetype)modelWithDic:(NSDictionary *)dic;

- (NSString *)readmeUrl;

@end
