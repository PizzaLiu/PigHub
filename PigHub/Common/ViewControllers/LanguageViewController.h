//
//  LanguageViewController.h
//  PigHub
//
//  Created by Rainbow on 2016/12/24.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageModel.h"

@interface LanguageViewController : UITableViewController

@property (nonatomic, strong) NSString *selectedLanguageQuery;
@property (nonatomic, strong) NSString *selectedLanguageName;
@property(nonatomic, copy) void (^dismissBlock)(Language *);

@end
