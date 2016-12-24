//
//  ExtendedNavBarView.m
//  PigHub
//
//  Created by Rainbow on 2016/12/19.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import "SegmentBarView.h"

@implementation SegmentBarView

- (instancetype)init
{
    self = [super init];

    self.clipsToBounds = YES;
    [self setTranslucent:YES];

    CALayer *bottomBorder = [CALayer layer];
    CGFloat borderWidth = 1.0f / [UIScreen mainScreen].scale;
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.25f alpha:0.25f].CGColor;

    [self.layer addSublayer:bottomBorder];

    return self;
}


@end
