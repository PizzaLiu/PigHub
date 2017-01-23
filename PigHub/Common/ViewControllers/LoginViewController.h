//
//  LoginViewController.h
//  PigHub
//
//  Created by Rainbow on 2017/1/23.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) void (^callback) (NSString *code);

@end
