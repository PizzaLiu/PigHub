//
//  UserTableViewCell.m
//  PigHub
//
//  Created by Rainbow on 2017/1/21.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "UserTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatarImage.layer.cornerRadius = 5.0;
    self.avatarImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (float)cellHeight
{
    return 61;
}

- (void)setUser:(UserModel *)user
{
    self.nameLabel.text = user.name;
    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[user avatarUrlForSize:44]]
                        placeholderImage:[UIImage imageNamed:@"DefaultAvatar"]];
}

@end
