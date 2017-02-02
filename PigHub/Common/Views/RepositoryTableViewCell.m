//
//  RepositoryCellViewTableViewCell.m
//  PigHub
//
//  Created by Rainbow on 2017/1/11.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepositoryTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation RepositoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatarImage.layer.cornerRadius = 5.0;
    self.avatarImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRepo:(RepositoryModel *)repo
{
    _repo = repo;

    self.nameLabel.text = repo.name;
    self.descLabel.text = repo.desc;
    self.starLabel.text = repo.starCount;
    self.ownerLabel.text = repo.orgName;
    self.langLabel.text = repo.langName;
    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[repo avatarUrlForSize:50]]
                        placeholderImage:[UIImage imageNamed:@"DefaultAvatar"]];
}

+ (float)cellHeight
{
    return 91;
}

@end
