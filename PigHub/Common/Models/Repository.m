//
//  Repository.m
//  PigHub
//
//  Created by Rainbow on 2017/1/8.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"
#import "Utility.h"

@implementation Repository

+ (NSDictionary *)spliteRepoPath:(NSString *)path
{
    NSRange range = [path rangeOfString:@"/"];
    if (range.length) {
        NSString *repoName = [path substringFromIndex:(range.location+1)];
        NSString *orgName = [path substringToIndex:(range.location)];
        return @{@"orgName": orgName, @"repoName": repoName};
    }
    return nil;
}

+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    Repository *repo = [[Repository alloc] init];

    if (repo) {
        NSDictionary *owner = [dic valueForKey:@"owner"];
        repo.name = [dic valueForKey:@"name"];
        repo.repoId = [dic valueForKey:@"id"];

        if (owner) {
            repo.orgName = [owner valueForKey:@"login"];
            repo.avatarUrl = [owner valueForKey:@"avatar_url"];
        }
        repo.desc = [dic valueForKey:@"description"] == (id)[NSNull null] ?  @"" : [dic valueForKey:@"description"];
        repo.langName = [dic valueForKey:@"language"] == (id)[NSNull null] ? @"" : [dic valueForKey:@"language"];
        repo.starCount =[Utility formatNumberForInt:[[dic valueForKey:@"stargazers_count"] intValue]];
        // repo.starCount = [[dic valueForKey:@"stargazers_count"] stringValue];
        repo.href = [dic valueForKey:@"html_url"] ? [dic valueForKey:@"html_url"] : [NSString stringWithFormat:@"https://github.com/%@", repo.name];

        NSDictionary *repoPath = [Repository spliteRepoPath:repo.name];
        if (repoPath) {
            repo.orgName = [repoPath objectForKey:@"orgName"];
            repo.name = [repoPath objectForKey:@"repoName"];
        }
    }

    return repo;
}

- (NSString *)avatarUrlForSize:(int)size
{
    int realSize = [UIScreen mainScreen].scale * size;
    return [NSString stringWithFormat:@"%@?s=%d", self.avatarUrl, realSize];
}

@end
