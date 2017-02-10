//
//  UserModel.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "UserModel.h"
#import <UIKit/UIKit.h>
#import "Utility.h"

@implementation UserModel

+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    UserModel *user = [[[self class] alloc] init];

    if (user) {
        user.name = [dic valueForKey:@"login"];
        user.avatarUrl = [dic valueForKey:@"avatar_url"];
        user.href = [dic valueForKey:@"html_url"] ? [dic valueForKey:@"html_url"] : [NSString stringWithFormat:@"https://github.com/%@", user.name];
        user.score = [[dic valueForKey:@"score"] floatValue];

        if ([dic valueForKey:@"name"]) {
            user.fullName = [dic valueForKey:@"name"];
            user.company = [dic valueForKey:@"company"] == (id)[NSNull null] ? @"" : [dic valueForKey:@"company"];
            user.blog = [dic valueForKey:@"blog"] == (id)[NSNull null] ? @"" : [dic valueForKey:@"blog"];
            user.location = [dic valueForKey:@"location"] == (id)[NSNull null] ? @"" : [dic valueForKey:@"location"];
            user.email = [dic valueForKey:@"email"] == (id)[NSNull null] ? @"" : [dic valueForKey:@"email"];
            user.bio = [dic valueForKey:@"bio"] == (id)[NSNull null] ? @"" : [dic valueForKey:@"bio"];
            user.reposUrl = [dic valueForKey:@"repos_url"];
            user.reposCount = [[dic valueForKey:@"public_repos"] integerValue];
            user.followersUrl = [dic valueForKey:@"followers_url"];
            user.followersCount = [[dic valueForKey:@"followers"] integerValue];

            user.updatedDate = [Utility formatZdateForString:[dic objectForKey:@"updated_at"]];
            user.createdDate = [Utility formatZdateForString:[dic objectForKey:@"created_at"]];
        }
    }

    return user;
}

- (NSString *)avatarUrlForSize:(int)size
{
    int realSize = [UIScreen mainScreen].scale * size;

    if ([self.avatarUrl containsString:@"?"]) {
        return [NSString stringWithFormat:@"%@&s=%d", self.avatarUrl, realSize];
    }
    return [NSString stringWithFormat:@"%@?s=%d", self.avatarUrl, realSize];
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
