//
//  NotificationTableViewCell.m
//  PigHub
//
//  Created by Rainbow on 2017/1/27.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

+ (float)cellHeight
{
    return 64.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
