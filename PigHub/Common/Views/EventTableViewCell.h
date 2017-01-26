//
//  EventTableViewCell.h
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModel.h"

@interface EventTableViewCell : UITableViewCell

@property (weak, nonatomic) EventModel *eventModel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *actorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceRepoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

+ (float)cellHeight;

@end
