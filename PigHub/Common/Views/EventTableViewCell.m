//
//  EventTableViewCell.m
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "EventTableViewCell.h"
#import "DateTools.h"

@implementation EventTableViewCell

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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)setEventModel:(EventModel *)event
{
    self.actorNameLabel.text = event.actor.name;
    self.actionNameLabel.text = event.actionName;
    self.sourceRepoNameLabel.text = [NSString stringWithFormat:@"%@/%@", event.sourceRepo.orgName, event.sourceRepo.name];
    self.dateLabel.text = event.createdDate.timeAgoSinceNow;
    switch (event.eventType) {
        case GitHubUserEventTypeFork:
            self.iconImageView.image = [UIImage imageNamed:@"Fork20"];
            break;
        case GitHubUserEventTypeComment:
            self.iconImageView.image = [UIImage imageNamed:@"Comment20"];
            break;
        case GitHubUserEventTypePull:
            self.iconImageView.image = [UIImage imageNamed:@"Merge20"];
            break;
        case GitHubUserEventTypePush:
            self.iconImageView.image = [UIImage imageNamed:@"Push20"];
            break;
        case GitHubUserEventTypeIssue:
            self.iconImageView.image = [UIImage imageNamed:@"Issue20"];
            break;
        case GitHubUserEventTypeWatch:
            if ([event.actionName isEqualToString:@"started"]) {
                self.iconImageView.image = [UIImage imageNamed:@"Star20"];
                break;
            }
        default:
            self.iconImageView.image = [UIImage imageNamed:@"Repository20"];
            break;
    }
}

@end
