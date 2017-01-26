//
//  UserModel.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "UserModel.h"
#import <UIKit/UIKit.h>

@implementation UserModel

+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    UserModel *user = [[UserModel alloc] init];

    if (user) {
        user.name = [dic valueForKey:@"login"];
        user.avatarUrl = [dic valueForKey:@"avatar_url"];
        user.href = [dic valueForKey:@"html_url"] ? [dic valueForKey:@"html_url"] : [NSString stringWithFormat:@"https://github.com/%@", user.name];
        user.score = [[dic valueForKey:@"score"] floatValue];
    }

    return user;
}

- (NSString *)avatarUrlForSize:(int)size
{
    int realSize = [UIScreen mainScreen].scale * size;
    return [NSString stringWithFormat:@"%@&s=%d", self.avatarUrl, realSize];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    [aCoder encodeObject:self.href forKey:@"href"];
    [aCoder encodeFloat:self.score forKey:@"score"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.avatarUrl = [aDecoder decodeObjectForKey:@"avatarUrl"];
        self.href = [aDecoder decodeObjectForKey:@"href"];
        self.score = [aDecoder decodeFloatForKey:@"score"];
    }

    return self;
}

@end
