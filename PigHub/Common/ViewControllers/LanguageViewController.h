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

@property (nonatomic, copy) NSString *selectedLanguageQuery;
@property (nonatomic, copy) NSString *selectedLanguageName;
@property(nonatomic, copy) void (^dismissBlock)(Language *);

@end
