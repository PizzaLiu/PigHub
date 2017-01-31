//
//  Repository.h
//  PigHub
//
//  Created by Rainbow on 2017/1/8.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepositoryModel : NSObject

@property (nonatomic, copy) NSString *repoId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *langName;
@property (nonatomic, copy) NSString *orgName;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *starCount;

+ (instancetype)modelWithDic:(NSDictionary *)dic;
- (NSString *) avatarUrlForSize:(int) size;

@end
