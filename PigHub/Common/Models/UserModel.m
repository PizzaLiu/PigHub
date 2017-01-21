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

- (NSString *)avatarUrlForSize:(int)size
{
    int realSize = [UIScreen mainScreen].scale * size;
    return [NSString stringWithFormat:@"%@&s=%d", self.avatarUrl, realSize];
}

@end
