//
//  NotificationModel.m
//  PigHub
//
//  Created by Rainbow on 2017/1/27.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "NotificationModel.h"
#import "Utility.h"

@implementation NotificationModel

+(instancetype)modelWithDic:(NSDictionary *)dic
{
    NotificationModel *model = [[NotificationModel alloc] init];

    NSDictionary *repoDic = [dic objectForKey:@"repository"];
    NSDictionary *subjectDic = [dic objectForKey:@"subject"];

    model.notiId = [dic objectForKey:@"id"];
    model.repoFullName = [repoDic objectForKey:@"full_name"];
    model.title = [subjectDic objectForKey:@"title"];
    model.updatedDateStr = [dic objectForKey:@"updated_at"];
    model.updatedDate = [Utility formatZdateForString:model.updatedDateStr];
    model.url = [NotificationModel transUrlToHtmlUrlWithUrl:[subjectDic objectForKey:@"url"]];

    return model;
}

+(NSString *)transUrlToHtmlUrlWithUrl:(NSString *)url
{
    NSString *htmlUrl = [[NSMutableString alloc] init];

    htmlUrl = [url stringByReplacingOccurrencesOfString:@"api.github.com" withString:@"github.com"];
    htmlUrl = [htmlUrl stringByReplacingOccurrencesOfString:@"/pulls/" withString:@"/pull/"];
    htmlUrl = [htmlUrl stringByReplacingOccurrencesOfString:@"/repos/" withString:@"/"];
    return htmlUrl;
}

@end
