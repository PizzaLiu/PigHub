//
//  UserModel.h
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, assign) float score;

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, copy) NSString *reposUrl;
@property (nonatomic, assign) NSInteger reposCount;
@property (nonatomic, copy) NSString *followersUrl;
@property (nonatomic, assign) NSInteger followersCount;

@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDate *updatedDate;

+ (instancetype)modelWithDic:(NSDictionary *)dic;
- (NSString *)avatarUrlForSize:(int)size;

@end
