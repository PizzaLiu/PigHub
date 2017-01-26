//
//  EventViewController.h
//  PigHub
//
//  Created by Rainbow on 2017/1/25.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface EventViewController : UITableViewController

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, weak) UserModel *loginedUser;

@end
