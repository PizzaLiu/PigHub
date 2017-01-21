//
//  UserTableViewCell.h
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (float) cellHeight;

@end
