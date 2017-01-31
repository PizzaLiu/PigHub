//
//  LoadingView.m
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (CGRectIsEmpty(frame)) {
            frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }
        // bg
        UIView *bg = [[UIView alloc] initWithFrame:frame];
        bg.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        [self addSubview:bg];

        // cycle
        int loadingViewWidth = 80;
        int loadingViewHeight = 80;
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - loadingViewWidth)/2.0, (frame.size.height - loadingViewHeight)/2.0, loadingViewWidth, loadingViewHeight)];
        loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
        loadingView.layer.cornerRadius = 5;

        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, 35);
        [activityView startAnimating];
        activityView.tag = 100;
        [loadingView addSubview:activityView];
        UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
        lblLoading.text = NSLocalizedString(@"Loading...", @"loading content");;
        lblLoading.textColor = [UIColor whiteColor];
        lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
        lblLoading.textAlignment = NSTextAlignmentCenter;
        [loadingView addSubview:lblLoading];

        [self addSubview:loadingView];
        self.hidden = YES;
    }
    return self;
}

@end
