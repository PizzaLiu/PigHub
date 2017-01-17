//
//  Repository.m
//  PigHub
//
//  Created by Rainbow on 2017/1/8.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "Repository.h"

@implementation Repository

- (NSString *)avatarUrlForSize:(int)size
{
    return [NSString stringWithFormat:@"%@?s=%d", self.avatarUrl, size];
}

@end
