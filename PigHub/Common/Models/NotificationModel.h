//
//  NotificationModel.h
//  PigHub
//
//  Created by Rainbow on 2017/1/27.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *notiId;
@property (nonatomic, copy) NSString *repoFullName;
@property (nonatomic, copy) NSString *updatedDateStr;
@property (nonatomic, strong) NSDate *updatedDate;

+(instancetype)modelWithDic:(NSDictionary *)dic;

@end
