//
//  UserModel.h
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, assign) float score;

- (NSString *)avatarUrlForSize:(int)size;

@end
