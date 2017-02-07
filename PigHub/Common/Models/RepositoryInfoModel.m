//
//  RepositoryInfoModel.m
//  PigHub
//
//  Created by Rainbow on 2017/1/29.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "RepositoryInfoModel.h"
#import "Utility.h"

@implementation RepositoryInfoModel

+(instancetype)modelWithDic:(NSDictionary *)dic
{
    RepositoryInfoModel *model = [[RepositoryInfoModel alloc] init];

    model.repoId = [dic objectForKey:@"id"];
    model.name = [dic objectForKey:@"name"];
    model.owner = [UserModel modelWithDic:[dic objectForKey:@"owner"]];
    model.lang = [dic objectForKey:@"language"] == (id)[NSNull null] ? @"" : [dic objectForKey:@"language"];
    model.homePage = [dic objectForKey:@"homepage"] == (id)[NSNull null] || [[dic objectForKey:@"homepage"] isEqualToString:@""] ? [NSString stringWithFormat:@"%@%@", @"http://github.com/", [dic objectForKey:@"full_name"]] : [dic objectForKey:@"homepage"];
    model.desc = [dic objectForKey:@"description"] == (id)[NSNull null] ? @"" : [dic objectForKey:@"description"];

    model.starCount = [[dic objectForKey:@"stargazers_count"] integerValue];
    model.forkCount = [[dic objectForKey:@"forks"] integerValue];
    model.watchCount = [[dic objectForKey:@"subscribers_count"] integerValue];

    model.parent = nil;
    if ([[dic objectForKey:@"fork"] boolValue]) {
        model.parent = [RepositoryModel modelWithDic:[dic objectForKey:@"parent"]];
    }

    model.htmlUrl = [dic objectForKey:@"html_url"];
    model.defaultBranch = [dic objectForKey:@"default_branch"];

    model.updatedDate = [Utility formatZdateForString:[dic objectForKey:@"pushed_at"]];
    model.createdDate = [Utility formatZdateForString:[dic objectForKey:@"created_at"]];

    return model;
}

-(NSString *)readmeUrl
{
    if (_readmeUrl) {
        return _readmeUrl;
    }
    return [NSString stringWithFormat:@"https://github.com/%@/%@/blob/%@/README.md", self.owner.name, self.name, self.defaultBranch];
}

- (NSString *)homePage
{
    if ([_homePage containsString:@"http"]) {
        return _homePage;
    }

    return [NSString stringWithFormat:@"http://%@", _homePage];
}

@end
