//
//  Repository.h
//  PigHub
//
//  Created by Rainbow on 2017/1/8.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repository : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *langName;
@property (nonatomic, strong) NSString *orgName;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *starCount;

- (NSString *) avatarUrlForSize:(int) size;

@end
