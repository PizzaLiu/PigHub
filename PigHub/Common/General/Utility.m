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

+ (NSDate *)formatZdateForString:(NSString *)dateStr
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        //dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        // 2017-01-24T08:54:29Z
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    }

    return [dateFormatter dateFromString:dateStr];
}

+ (NSString *)getShortDayFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd"];
    }
    return [formatter stringFromDate:date];
}

@end
