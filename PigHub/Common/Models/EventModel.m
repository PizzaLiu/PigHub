//
//  EventModel.m
//  PigHub
//
//  Created by Rainbow on 2017/1/24.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "EventModel.h"
#import "Utility.h"

@implementation EventModel


+ (instancetype)modelWithDic:(NSDictionary *)dic
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        //dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        // 2017-01-24T08:54:29Z
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    }

    if (!dic) {
        return nil;
    }

    EventModel *model = [[EventModel alloc] init];

    if (model) {
        NSString *typeStr = [dic objectForKey:@"type"];
        NSDictionary *payload = [dic objectForKey:@"payload"];

        model.actor = [UserModel modelWithDic:[dic objectForKey:@"actor"]];
        model.eventId = [dic objectForKey:@"id"];
        model.createdDate = [dateFormatter dateFromString: [dic objectForKey:@"created_at"]];
        model.sourceRepo = [Repository modelWithDic:[dic objectForKey:@"repo"]];
        model.isPulic = [[dic objectForKey:@"public"] boolValue];

        if ([typeStr isEqualToString:@"ForkEvent"]) {
            model.actionName = @"forked";
            model.eventType = GitHubUserEventTypeFork;
            model.destRepo = [Repository modelWithDic:[payload objectForKey:@"forkee"]];
        } else if ([typeStr isEqualToString:@"WatchEvent"]) {
            model.actionName = [payload objectForKey:@"action"];
            model.eventType = GitHubUserEventTypeWatch;
        } else if ([typeStr isEqualToString:@"CreateEvent"]) {
            model.actionName = @"created";
            model.eventType = GitHubUserEventTypeCreate;
        } else if ([typeStr isEqualToString:@"IssuesEvent"]) {
            model.actionName = [payload objectForKey:@"action"];
            model.eventType = GitHubUserEventTypeIssue;
            model.url = [[payload objectForKey:@"issue"]  objectForKey:@"html_url"];
            model.sourceRepo.name = [NSString stringWithFormat:@"%@#%@", model.sourceRepo.name, [[[payload objectForKey:@"issue"] objectForKey:@"number"] stringValue]];
        } else if ([typeStr isEqualToString:@"PullRequestEvent"]) {
            model.actionName = [payload objectForKey:@"action"];
            model.eventType = GitHubUserEventTypePull;
            model.url = [[payload objectForKey:@"pull_request"]  objectForKey:@"html_url"];
            model.sourceRepo.name = [NSString stringWithFormat:@"%@#%@", model.sourceRepo.name, [[payload objectForKey:@"number"] stringValue]];
        } else if ([typeStr isEqualToString:@"PushEvent"]) {
            // TODO: deal with more than 1 commit
            model.actionName = @"pushed to";
            model.eventType = GitHubUserEventTypePush;
            model.url = [NSString stringWithFormat:@"https://github.com/%@/%@/commit/%@", model.sourceRepo.orgName, model.sourceRepo.name, [[[payload objectForKey:@"commits"] objectAtIndex:0] objectForKey:@"sha"]];
        } else if ([payload objectForKey:@"comment"]) {
            model.actionName = @"commented";
            model.url = [[payload objectForKey:@"comment"]  objectForKey:@"html_url"];
            model.eventType = GitHubUserEventTypeComment;
            if ([typeStr isEqualToString:@"IssueCommentEvent"]) {
                model.sourceRepo.name = [NSString stringWithFormat:@"%@#%@", model.sourceRepo.name, [[[payload objectForKey:@"issue"] objectForKey:@"number"] stringValue]];
            } else if ([typeStr isEqualToString:@"PullRequestReviewCommentEvent"]) {
                model.sourceRepo.name = [NSString stringWithFormat:@"%@#%@", model.sourceRepo.name, [[[payload objectForKey:@"pull_request"] objectForKey:@"number"] stringValue]];
            }
        } else {
            model.eventType = GitHubUserEventTypeUnknow;
        }
    }

    return model;
}

- (NSString *)description
{
    if (self.eventType & GitHubUserEventTypeFork) {
        return [NSString stringWithFormat:@"%@ %@ %@ to %@", self.actor.name, self.actionName, self.sourceRepo.name, self.destRepo.name];
    } else {
        return [NSString stringWithFormat:@"%@ %@ %@", self.actor.name, self.actionName, self.sourceRepo.name];
    }
}

@end
