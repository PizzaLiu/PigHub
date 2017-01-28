//
//  Utility.h
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString *)trimString:(NSString *) str;
+ (NSString *)formatNumberForInt:(NSInteger)num;
+ (NSDate *)formatZdateForString:(NSString *)dateStr;

@end
