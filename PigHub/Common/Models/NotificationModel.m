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

+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    NotificationModel *model = [[[self class] alloc] init];

    NSDictionary *repoDic = [dic objectForKey:@"repository"];
    NSDictionary *subjectDic = [dic objectForKey:@"subject"];

    model.notiId = [dic objectForKey:@"id"];
    model.repoFullName = [repoDic objectForKey:@"full_name"];
    model.title = [subjectDic objectForKey:@"title"];
    model.updatedDateStr = [dic objectForKey:@"updated_at"];
    model.updatedDate = [Utility formatZdateForString:model.updatedDateStr];
    model.url = [subjectDic objectForKey:@"url"];

    return model;
}

@end
