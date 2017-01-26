//
//  Utility.m
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (NSString *)trimString:(NSString *) str
{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)formatNumberForInt:(NSInteger)num
{
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setAlwaysShowsDecimalSeparator:NO];
    }

    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

@end
