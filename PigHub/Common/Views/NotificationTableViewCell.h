//
//  NotificationTableViewCell.h
//  PigHub
//
//  Created by Rainbow on 2017/1/27.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *repoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

+ (float)cellHeight;

@end
